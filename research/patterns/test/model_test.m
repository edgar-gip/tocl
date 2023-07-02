%% -*- mode:octave; -*-

%% Packages
pkg load octopus;

%% Warnings
warning off Octave:divide-by-zero;

%% DEBUG
%% debug_on_interrupt(true());

%% Constants
%% n_noise  = 20;
%% n_signal =  5;
n_tries  =    1;
n_dims   =    2;
n_noise  = 1000;
k_signal =    3;
n_signal =   50;
v_noise  =    5.0;
v_signal =    0.5;
s_signal =    3.5;

%% Distances
d_rbf = KernelDistance(RBFKernel(1.0));
d_sqe = SqEuclideanDistance();
d_mah = @(data) MahalanobisDistance(data);

%% Clusterer Constructors
c_hy_sqe = @(data) HyperBB (d_sqe,       struct("size_ratio", 0.1));
c_hy_mah = @(data) HyperBB (d_mah(data), struct("size_ratio", 0.1));
c_bp_sqe = @(data) BBCPress(d_sqe,       struct("size_ratio", 0.1));
c_bp_mah = @(data) BBCPress(d_mah(data), struct("size_ratio", 0.1));
c_ew_sqe = @(data) EWOCS(Voronoi(d_sqe),       struct("ensemble_size", 50));
c_ew_mah = @(data) EWOCS(Voronoi(d_mah(data)), struct("ensemble_size", 50));
c_ew_rbf = @(data) EWOCS(Voronoi(d_rbf),       struct("ensemble_size", 50));

%% Clusterers set
clusterers = struct("constr", { c_hy_sqe, c_hy_mah, ...
                                c_bp_sqe, c_bp_mah, ...
                                c_ew_sqe, c_ew_mah, c_ew_rbf },         ...
                    "name",   { "HyperBB - SqE",    "HyperBB - Mah",    ...
                                "BBCPress/3 - SqE", "BBCPress/3 - Mah", ...
                                "EWOCS - SqE",      "EWOCS - Mah",      ...
                                "EWOCS - RBF" }, ...
                    "k",      {  1, 1, 3, 3, 1, 1, 1 });
n_clusterers = length(clusterers);

%% ROC curves

%% Tries
for i = 1 : n_tries
  %% Accumulated data and circles
  data    = [];
  circles = {};

  %% Generate the noise
  noise = v_noise * (rand(n_dims, n_noise) - 0.5);
  data  = [ data, noise ];

  %% For each signal cluster
  for c = 1 : k_signal
    %% mean   = s_signal * [ cos(2 * pi * c / k_signal) ; ...
    %%                       sin(2 * pi * c / k_signal) ];

    %% Mean
    mean      = s_signal * (rand(n_dims, 1) - 0.5);

    %% Variance
    project   = rand(n_dims, n_dims) - 0.5;
    project ./= ones(n_dims, 1) * sqrt(sum(project .* project));
    variance  = project * diag(v_signal * rand(n_dims, 1), 0);

    %% Signal
    signal    = variance * randn(n_dims, n_signal) + mean * ones(1, n_signal);
    data      = [ data, signal ];

    %% Circle
    if n_dims == 2
      circle  = variance * [ cos(pi / 4 * (1 : 9)) ; ...
                             sin(pi / 4 * (1 : 9)) ] + mean * ones(1, 9);
      circles = cell_push(circles, circle(1, :), circle(2, :), "g-",
                          "linewidth", 2);
    endif
  endfor

  %% Truth
  truth = [ zeros(1, n_noise), ones(1, k_signal * n_signal) ];

  %% Number of data
  n_data = length(truth);

  %% Now, confuse everything
  shuffler = randperm(n_data);
  data     = data (:, shuffler);
  truth    = truth(shuffler);

  %% Negative and positive indices
  neg_tr = find(~truth);
  pos_tr = find( truth);

  %% Plot data
  if n_dims == 2
    figure();
    plot(data(1, pos_tr), data(2, pos_tr), 'g*', ...
         data(1, neg_tr), data(2, neg_tr), 'r+', ...
         circles{:});
    title("Truth");
  endif

  %% ROC plots
  roc_plots = {};

  %% New figure
  %% figure();

  %% Cluster
  j = 0;
  for c = clusterers
    %% Construct it
    cl_object = c.constr(data);

    %% One more
    j += 1;

    %% Cluster (timed)
    [ total0, user0, system0 ] = cputime();
    [ expec, cl_model ] = cluster(cl_object, data, c.k);
    [ total1, user1, system1 ] = cputime();

    %% Display the difference
    cl_time = total1 - total0;

    %% Model is OK
    expec1 = expectation(cl_model, data);
    diffs  = abs(expec - expec1);
    if ~all(all(diffs < 1e-6))
      [ rows, cols ] = find(diffs >= 1e-6);
      for k = 1 : length(rows)
        ri = rows(k);
        ci = cols(k);
        fprintf(2, "(%d, %d) -> %g -> %g  ", ...
                ri, ci, expec(ri, ci), expec1(ri, ci));
        if mod(k, 5) == 0
          fprintf(2, "\n");
        endif
      endfor
      if mod(length(rows), 5) ~= 0
        fprintf(2, "\n");
      endif
      error("Model %s is not working fine", c.name);
    endif

    %% Negative/positive cluster
    sexpec = sum(expec, 1);
    pos_cl = find(sexpec >= 0.5);
    neg_cl = find(sexpec < 0.5);

    %% Intersections
    pos_pos = intersect(pos_tr, pos_cl);
    pos_neg = intersect(pos_tr, neg_cl);
    neg_pos = intersect(neg_tr, pos_cl);
    neg_neg = intersect(neg_tr, neg_cl);

    %% Sizes
    n_pos_pos = length(pos_pos);
    n_pos_neg = length(pos_neg);
    n_neg_pos = length(neg_pos);

    %% Precision/Recall
    cl_prc = n_pos_pos / (n_pos_pos + n_neg_pos);
    cl_rec = n_pos_pos / (n_pos_pos + n_pos_neg);
    cl_f1  = 2 * cl_prc * cl_rec / (cl_prc + cl_rec);

    %% plot
    if n_dims == 2
      figure();
      subplot(1, 2, 1);
      plot(data(1, pos_pos),  data(2, pos_pos),  'g*',
           data(1, pos_neg),  data(2, pos_neg),  'b*',
           data(1, neg_pos),  data(2, neg_pos),  'r+',
           data(1, neg_neg),  data(2, neg_neg),  'y+',
           circles{:});
      title(c.name);
    endif

    %% Find ROC curve

    %% Scores
    scores = score(cl_model, data);

    %% Sort'em
    [ sort_scores, sort_idx ] = sort(scores, "descend");

    %% Find accumulated positive and negative
    roc_pos = cumsum( truth(sort_idx)); roc_pos ./= roc_pos(n_data);
    roc_neg = cumsum(~truth(sort_idx)); roc_neg ./= roc_neg(n_data);

    %% AUC
    cl_auc = sum(diff(roc_neg) .* ...
                 (roc_pos(1 : n_data - 1) + roc_pos(2 : n_data))) / 2;

    %% Add to ROC plots
    roc_plots = cell_push(roc_plots, ...
                          roc_neg, roc_pos, sprintf("-;%s;", c.name));

    %% Plots scores
    if n_dims == 2
      subplot(1, 2, 2);
      plot3(data(1, pos_cl), data(2, pos_cl), scores(pos_cl), 'gx',
            data(1, neg_cl), data(2, neg_cl), scores(neg_cl), 'rx');
      title(c.name);
    endif

    %% Display
    printf("%s -> t=%8g p=%.3f r=%.3f f1=%.3f auc=%.3f\n", ...
           c.name, cl_time, cl_prc, cl_rec, cl_f1, cl_auc);
  endfor

  %% Plot ROC
  figure();
  plot([ 0, 1 ], [ 0, 1 ], "-;Random;", roc_plots{:});
  title("ROC Curves");
  legend("location", "southeast");
endfor

pause;
