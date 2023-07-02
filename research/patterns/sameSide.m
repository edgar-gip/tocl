%% -*- mode: octave; -*-

%% Fraction of pairs that are in the same class

%% Author: Edgar Gonzàlez i Pellicer


%% Octopus
pkg load octopus

%% Warnings
warning off Octave:divide-by-zero;


%%%%%%%%%%%
%% Enums %%
%%%%%%%%%%%

%% Task
enum T_SAME_SIDE T_SCORE_HISTO

%% Distributions
enum P_BERNOULLI P_GAUSSIAN P_SPHERICAL P_UNIFORM

%% Inside weak clustering methods
%% enum C_BERNOULLI C_KMEANS C_SVM C_VORONOI
enum C_BERNOULLI C_GAUSSIAN C_RANDOM C_VORONOI

%% Distance
enum D_EUCLIDEAN D_KERNEL D_MAHALANOBIS

%% Kernels
enum K_LINEAR K_POLYNOMIAL K_RBF


%%%%%%%%%%%%%
%% Options %%
%%%%%%%%%%%%%

%% Set signal-size
function [ opts ] = s_signal_size(opts, value)
  opts.signal_size = cellfun(@str2double, regex_split(value, '(,|\s+,)\s*'));
endfunction

%% Set clusters
function [ opts ] = s_clusters(opts, value)
  opts.min_clusters = opts.max_clusters = value;
endfunction

%% Set hard alpha
function [ opts ] = s_hard_alpha(opts, value)
  opts.soft_alpha = inf;
endfunction

%% Default options
def_opts                 = struct();
def_opts.task            = T_SAME_SIDE;
def_opts.seed            = [];
def_opts.sparse          = false();
def_opts.outer_runs      = 5;
def_opts.inner_runs      = 100;
def_opts.do_plot         = false();
def_opts.pause_time      = 1;
def_opts.dimensions      = 2;
def_opts.noise_size      = 1000;
def_opts.noise_dist      = P_UNIFORM;
def_opts.noise_mean      = 0.0;
def_opts.noise_var       = 10.0;
def_opts.signal_groups   = 1;
def_opts.signal_size     = 100;
def_opts.signal_dist     = P_GAUSSIAN;
def_opts.signal_shift    = 2.5;
def_opts.signal_space    = 2.5;
def_opts.signal_var      = 1.0;
def_opts.min_clusters    = 2;
def_opts.max_clusters    = 20;
def_opts.ensemble_size   = 100;
def_opts.clusterer       = C_VORONOI;
def_opts.em_iterations   = 100;       %% For C_BERNOULLI
def_opts.em_threshold    = 1e-6;      %% For C_BERNOULLI
def_opts.distance        = D_KERNEL;  %% For C_VORONOI
def_opts.kernel          = K_RBF;     %% For D_KERNEL
def_opts.poly_degree     = 2;         %% For K_POLYNOMIAL
def_opts.poly_constant   = true();    %% For K_POLYNOMIAL
def_opts.rbf_gamma       = 0.1;       %% For K_RBF
def_opts.soft_alpha      = 0.1;       %% For C_VORONOI
def_opts.histo_bins      = 100;

%% Parse options
[ cmd_args, cmd_opts ] = ...
    get_options(def_opts, ...
                "same-side=r0",       "task",          ...
                "score-histo=r1",     "task",          ...
                "seed=f",             "seed",          ...
                "sparse!",            "sparse",        ...
                "outer-runs=i",       "outer_runs",    ...
                "inner-runs=i",       "inner_runs",    ...
                "do-plot!",           "do_plot",       ...
                "pause-time=f",       "pause_time",    ...
                "dimensions=i",       "dimensions",    ...
                "noise-size=i",       "noise_size",    ...
                "noise-bernoulli=r0", "noise_dist",    ...
                "noise-gaussian=r1",  "noise_dist",    ...
                "noise-spherical=r2", "noise_dist",    ...
                "noise-uniform=r3",   "noise_dist",    ...
                "noise-mean=f",       "noise_mean",    ...
                "noise-var=f",        "noise_var",     ...
                "signal-groups=i",    "signal_groups", ...
                "signal-size=s",      @s_signal_size,  ...
                "signal-bernoulli=r0","signal_dist",   ...
                "signal-gaussian=r1", "signal_dist",   ...
                "signal-spherical=r2","signal_dist",   ...
                "signal-uniform=r3",  "signal_dist",   ...
                "signal-shift=f",     "signal_shift",  ...
                "signal-space=f",     "signal_space",  ...
                "signal-var=f",       "signal_var",    ...
                "min-clusters=i",     "min_clusters",  ...
                "max-clusters=i",     "max_clusters",  ...
                "ensemble-size=i",    "ensemble_size", ...
                "clusters=i",         @s_clusters,     ...
                "ewocs-bernoulli=r0", "clusterer",     ...
                "ewocs-gaussian=r1",  "clusterer",     ...
                "ewocs-random=r2",    "clusterer",     ...
                "ewocs-voronoi=r3",   "clusterer",     ...
                "em-iterations=i",    "em_iterations", ...
                "em-threshold=f",     "em_threshold",  ...
                "euclidean-dist=r0",  "distance",      ...
                "kernel-dist=r1",     "distance",      ...
                "linear-kernel=r0",   "kernel",        ...
                "poly-kernel=r1",     "kernel",        ...
                "rbf-kernel=r2",      "kernel",        ...
                "poly-degree=i",      "poly_degree",   ...
                "poly-constant!",     "poly_constant", ...
                "rbf-gamma=f",        "rbf_gamma",     ...
                "hard-alpha",         @s_hard_alpha,   ...
                "soft-alpha=f",       "soft_alpha",    ...
                "histo-bins=i",       "histo_bins");

%% Set a seed
if ~isempty(cmd_opts.seed)
  set_all_seeds(cmd_opts.seed);
endif

%% No plots for more than three dimensions
if cmd_opts.dimensions > 3
  warning("Cannot plot more than three dimensional data");
  cmd_opts.do_plot = false();
endif

%% Expand signal_size
if length(cmd_opts.signal_size) == 1
  cmd_opts.signal_size = ...
      cmd_opts.signal_size * ones(1, cmd_opts.signal_groups);
else
  cmd_opts.signal_groups = length(cmd_opts.signal_size);
endif

% Number of clusters range
cmd_opts.range_clusters = cmd_opts.max_clusters - cmd_opts.min_clusters;


%%%%%%%%%%%%%
%% Calculi %%
%%%%%%%%%%%%%

%% Prc/Rec curves
function [ prc, rec, f1 ] = prc_rec(sort_scores, sort_idx, s_truth)

  %% Size
  n_data = length(sort_idx);

  %% Find the curves
  acc_pos = cumsum( s_truth(sort_idx));
  acc_neg = cumsum(~s_truth(sort_idx));

  %% Prc/Rec/F1
  prc = acc_pos ./ (acc_pos .+ acc_neg);
  rec = acc_pos ./  acc_pos(n_data);
  f1  = (2 .* prc .* rec) ./ (prc .+ rec);
endfunction

%% Score plots
function [ plots, max_histo ] = score_histo_plots(scores, expec, histo_bins)

  %% Sizes
  [ k, elems ] = size(expec);

  %% Min/max
  min_score = min(scores);
  max_score = max(scores);

  %% Histogram
  h = Histogram();

  %% Plots
  plots   = {};
  max_bin = 0;

  %% For each cl
  for cl = 1 : k

    %% Cluster
    cluster = find(expec(cl, :));

    %% Histogram
    [ histo, bin_limits ] = ...
        make(h, scores(cluster), histo_bins, min_score, max_score);

    %% Is it the noise cluster?
    if cl == 1
      plots = cell_push(plots, bin_limits, histo, "-r", "linewidth", 2);
    else
      plots = cell_push(plots, bin_limits, histo, "-g");
    endif
  endfor

  %% Truth cluster
  truth_cluster = find(sum(expec(2 : k, :)));

  %% Histogram
  [ histo, bin_limits ] = ...
      make(h, scores(truth_cluster), histo_bins, min_score, max_score);
  plots = cell_push(plots, bin_limits, histo, "-g", "linewidth", 2);

  %% All histogram
  [ histo, bin_limits ] = ...
      make(h, scores, histo_bins, min_score, max_score);
  plots = cell_push(plots, bin_limits, histo, "-k", "linewidth", 2);

  %% Max
  max_histo = max(histo);
endfunction

%% Gaussian model plots
function [ model_plots, sorted_cl ] = ...
      gaussian_model_plots(model, max_histo, color)

  %% Model info
  als = alphas(model);
  mns = means(model);
  std = sqrt(variances(model));

  %% Number of clusters
  k = length(als);

  %% Sort the clusters
  [ sorted_mns, sorted_cl ] = sort(mns, "descend");

  %% Xs and Ps
  xs = zeros(k, 21);
  ps = zeros(k, 21);

  %% For each cluster
  for c = 1 : k
    %% Get 21 points Within 2 stdevs
    xs(c, :) = mns(c) + (-10 : 10) * std(c) / 10;

    %% Find a scaled density
    ps(c, :) = als(c) * normpdf(xs(c, :), mns(c), std(c));
  endfor

  %% Scale
  max_p = max(max(ps));
  ps   *= max_histo / max_p;

  %% For each cluster
  model_plots = {};
  for c = 1 : k
    %% Add it
    model_plots = cell_push(model_plots, xs(c, :), ps(c, :), color);
  endfor
endfunction


%%%%%%%%%%%%%%
%% Plotting %%
%%%%%%%%%%%%%%

%% Do the expectation plot
function do_plot_expec(window, data, expec, pause_time)

  %% Sizes
  [ dims, elems ] = size(data);
  [ k,    elems ] = size(expec);

  %% Plots
  plots = {};

  %% For each cl
  for cl = 1 : k
    %% Elements
    cluster = find(expec(cl, :));

    %% Add their data
    if dims == 2
      plots = cell_push(plots, ...
                        data(1, cluster), data(2, cluster), "x");
    else %% dims == 3
      plots = cell_push(plots, ...
                        data(1, cluster), data(2, cluster), ...
                        data(3, cluster), "x");
    endif
  endfor

  %% Plot
  figure(window);
  if dims == 2
    plot(plots{:});
  else
    plot3(plots{:});
  endif

  %% Stop?
  if pause_time > 0
    pause(pause_time);
  endif
endfunction

%% Plot
function do_plot_score_data(window, data, s_truth, scores, pause_time)

  %% Indices
  neg = find(~s_truth);
  pos = find( s_truth);

  %% Size
  [ n_dims, n_data ] = size(data);

  %% What?
  if n_dims == 2
    %% Plot
    figure(window);
    plot3(data(1, neg), data(2, neg), scores(neg), "+", ...
          data(1, pos), data(2, pos), scores(pos), "*");

  else %% n_dims == 3
    %% Contours
    min_score = min(scores);
    max_score = max(scores);

    %% Range
    if min_score == max_score
      %% Just plot positives and negatives
      figure(window);
      plot3(data(1, neg), data(2, neg), data(3, neg), "+r",
            data(1, pos), data(2, pos), data(3, pos), "*r");

    else
      %% Range
      range = max_score - min_score;

      %% Bins
      bins = 1 + floor((scores - min_score) / (range / 4));
      bins(bins == 5) = 4;

      %% Colours
      colours = { "r", "y", "g", "b" };

      %% Plots
      plots = {};
      for g = 1 : 4
        %% Neg
        neg_x = intersect(neg, find(bins == g));
        if ~isempty(neg_x)
          plots = ...
              cell_push(plots, ...
                        data(1, neg_x), data(2, neg_x), data(3, neg_x), ...
                        sprintf("+%s", colours{g}));
        endif

        %% Pos
        pos_x = intersect(pos, find(bins == g));
        if ~isempty(pos_x)
          plots = ...
              cell_push(plots, ...
                        data(1, pos_x), data(2, pos_x), data(3, pos_x), ...
                        sprintf("*%s", colours{g}));
        endif
      endfor

      %% Plot
      figure(window);
      plot3(plots{:});
    endif
  endif

  %% Stop?
  if pause_time > 0
    pause(pause_time);
  endif
endfunction

%% Do the distance plot
function [ min_knee_idx ] = ...
      do_plot_dist(dist_fig, map_sort_scores, f1, pause_time)

  %% Size
  n_data = length(map_sort_scores);

  %% Find the distance
  knee_idx_n = (0 : (n_data - 1)) ./ (n_data - 1);
  knee_dist  = map_sort_scores .* map_sort_scores + knee_idx_n .* knee_idx_n;

  %% Minimum point
  [ min_knee_dist, min_knee_idx ] = min(knee_dist);

  %% Plot
  figure(dist_fig);
  plot(map_sort_scores, "-k;Score;", "linewidth", 2, ...
       f1, "-m;F1;", "linewidth", 2, ...
       knee_dist, "-b;Distance;", ...
       [ min_knee_idx,  min_knee_idx ], ...
       [ min_knee_dist, f1(min_knee_idx) ], "x-b");

  %% Stop?
  if pause_time > 0
    pause(pause_time);
  endif
endfunction

%% Do the gaussian plot
function [ gauss_cut_idx ] = ...
      do_plot_gauss(gauss_fig, sort_scores, map_sort_scores, f1, ...
                    histo_plots, max_histo, pause_time)

  %% Model
  [ expec, model ] = cluster(Gaussian1D(), sort_scores, 2);

  %% Gaussian model plots
  [ model_plots, sorted_cl ] = gaussian_model_plots(model, max_histo, "-b");

  %% Cut point
  gauss_expec_tru = expec(sorted_cl(1), :);
  gauss_cut_idx   = last_downfall(gauss_expec_tru, 0.5);

  %% Plot
  figure(gauss_fig);
  subplot(1, 2, 1);
  plot(map_sort_scores, "-k;Score;", "linewidth", 2, ...
       f1, "-m;F1;", "linewidth", 2, ...
       gauss_expec_tru, "-r;Gaussian;", ...
       [ gauss_cut_idx, gauss_cut_idx ], ...
       [ gauss_expec_tru(gauss_cut_idx), f1(gauss_cut_idx) ], "x-r");
  subplot(1, 2, 2);
  plot(histo_plots{:}, model_plots{:});

  %% Stop?
  if pause_time > 0
    pause(pause_time);
  endif
endfunction

%% Do the gaussian noise plot
function [ gauss_cut_idx ] = ...
      do_plot_gaussn(gauss_fig, sort_scores, map_sort_scores, f1, ...
                     histo_plots, max_histo, pause_time)

  %% Model
  [ expec, model ] = cluster(Gaussian1DNoise(), sort_scores, 3);

  %% Gaussian model plots
  [ model_plots, sorted_cl ] = gaussian_model_plots(model, max_histo, "-b");

  %% Cut point
  gauss_expec_tru = expec(sorted_cl(1), :);
  gauss_cut_idx   = last_downfall(gauss_expec_tru, 0.5);

  %% Plot
  figure(gauss_fig);
  subplot(1, 2, 1);
  plot(map_sort_scores, "-k;Score;", "linewidth", 2, ...
       f1, "-m;F1;", "linewidth", 2, ...
       gauss_expec_tru, "-r;Gaussian;", ...
       [ gauss_cut_idx, gauss_cut_idx ], ...
       [ gauss_expec_tru(gauss_cut_idx), f1(gauss_cut_idx) ], "x-r");
  subplot(1, 2, 2);
  plot(histo_plots{:}, model_plots{:});

  %% Stop?
  if pause_time > 0
    pause(pause_time);
  endif
endfunction

%% Do the multi gaussian plot
function [ mgauss_cut_idx ] = ...
      do_plot_mgauss(mgauss_fig, mgauss_expec_fig, data, ...
                     sort_scores, sort_idx, map_sort_scores, ...
                     f1, histo_plots, max_histo, pause_time)

  %% Model
  [ expec, model ] = cluster(CriterionClusterer(Gaussian1DNoise(), BIC(),
                                                struct("max_k", 10)),
                             sort_scores);

  %% Gaussian model plots
  [ model_plots, sorted_cl ] = gaussian_model_plots(model, max_histo, "-b");

  %% Plots, and best cut point
  plots    = {};
  best_f1  = 0.0;
  best_c   = -1;
  best_idx = -1;

  %% Find it
  for c = 1 : length(sorted_cl) - 1

    %% Expec
    expec_tru = sum(expec(sorted_cl(1 : c), :), 1);
    cut_idx   = last_downfall(expec_tru, 0.5);

    %% Add plots
    plots = cell_push(plots, ...
                      expec_tru, sprintf("-r;M-Gaussian-%d;", c), ...
                      [ cut_idx, cut_idx ], ...
                      [ expec_tru(cut_idx), f1(cut_idx) ], "x-r");

    %% Better?
    if f1(cut_idx) > best_f1
      best_f1  = f1(cut_idx);
      best_c   = c;
      best_idx = cut_idx;
    endif
  endfor

  %% Keep the best
  mgauss_cut_idx = best_idx;

  %% Change the plot color
  plots{5 * (best_c - 1) + 2} = sprintf("-b;M-Gaussian-%d;", best_c);

  %% Plot
  figure(mgauss_fig);
  subplot(1, 2, 1);
  plot(map_sort_scores, "-k;Score;", "linewidth", 2, ...
       f1, "-m;F1;", "linewidth", 2, ...
       plots{:});
  subplot(1, 2, 2);
  plot(histo_plots{:}, model_plots{:});

  %% Extra plot?
  if mgauss_expec_fig
    %% Size
    n_data = length(sort_scores);

    %% Harden it
    [ max_expec, max_cl ] = max(expec);
    h_expec = sparse(max_cl, sort_idx, ones(1, n_data), ...
                     length(sorted_cl), n_data);

    %% Plot it
    do_plot_expec(mgauss_expec_fig, data, h_expec, 0.0);
  endif

  %% Stop?
  if pause_time > 0
    pause(pause_time);
  endif
endfunction

%% Do the hard gaussian plot
function [ max_log_like_idx ] = ...
      do_plot_hgauss(hgauss_fig, sort_scores, map_sort_scores, f1, ...
                     histo_plots, max_histo, pause_time)

  %% Size
  n_data = length(map_sort_scores);

  %% Two-class Hard Gaussian log-likelihood

  %% Cummulated sums
  left_sum     = cumsum(sort_scores);
  left_sum_sq  = cumsum(sort_scores .* sort_scores);
  right_sum    = left_sum   (n_data) - [ 0,    left_sum(1 : n_data - 1) ];
  right_sum_sq = left_sum_sq(n_data) - [ 0, left_sum_sq(1 : n_data - 1) ];

  %% Means and variances
  left_mean  = left_sum     ./ (1 : n_data);
  left_var   = left_sum_sq  ./ (1 : n_data) - left_mean  .* left_mean;
  right_mean = right_sum    ./ (n_data : -1 : 1);
  right_var  = right_sum_sq ./ (n_data : -1 : 1) - right_mean .* right_mean;

  %% Cut points
  log_like = zeros(1, n_data - 1);
  for k = 1 : n_data - 1
    log_like(k) = + k * ...
                    log(1 / sqrt(2 * pi * left_var(k)) * k / n_data) ...
                  - sum(((sort_scores(1 : k) - left_mean(k)) .^ 2) ./ ...
                        (2 * left_var(k))) ...
                  + (n_data - k) * ...
                    log(1 / sqrt(2 * pi * right_var(k + 1)) * ...
                        (n_data - k) / n_data)...
                  - sum(((sort_scores(k + 1 : n_data) -
                          right_mean(k + 1)) .^ 2) ./ ...
                        (2 * right_var(k + 1)));
  endfor
  log_like = real(log_like);

  %% Cut
  [ max_log_like, max_log_like_idx ] = max(log_like);

  %% Map
  map_log_like = apply(LinearInterpolator(), log_like);

  %% Create a fake model
  alphas = [ max_log_like_idx / n_data, (n_data - max_log_like_idx) / n_data ];
  means  = [ left_mean(max_log_like_idx), right_mean(max_log_like_idx + 1) ];
  vars   = [ left_var(max_log_like_idx), right_var(max_log_like_idx + 1) ];
  model  = Gaussian1DModel(2, alphas, means, vars);

  %% Plot it
  [ model_plots ] = gaussian_model_plots(model, max_histo, "-b");

  %% Plot
  figure(hgauss_fig);
  subplot(1, 2, 1);
  plot(map_sort_scores, "-k;Score;", "linewidth", 2, ...
       f1, "-m;F1;", "linewidth", 2, ...
       map_log_like, "-r;Log-Like;", ...
       [ max_log_like_idx, max_log_like_idx ], ...
       [ map_log_like(max_log_like_idx), f1(max_log_like_idx) ], "x-r");
  subplot(1, 2, 2);
  plot(histo_plots{:}, model_plots{:});

  %% Stop?
  if pause_time > 0
    pause(pause_time);
  endif
endfunction

%% Do the Prc/Rec plot
function do_plot_prc_rec(prc_rec_fig, map_sort_scores, prc, rec, f1, ...
                         min_knee_idx, gauss_idx, gaussn_idx, mgauss_idx, ...
                         hgauss_idx, pause_time)

  %% Plot
  figure(prc_rec_fig);
  plot(map_sort_scores, "-k;Score;", "linewidth", 2, ...
       prc, "-r;Precision;", rec, "-b;Recall;", ...
       f1, "-m;F1;", "linewidth", 2, ...
       min_knee_idx, f1(min_knee_idx), "*b;Distance;", ...
       gauss_idx,    f1(gauss_idx),    "*r;2-Gaussian;", ...
       gaussn_idx,   f1(gaussn_idx),   "*y;2-Gaussian/N;", ...
       mgauss_idx,   f1(mgauss_idx),   "*c;M-Gaussian;", ...
       hgauss_idx,   f1(hgauss_idx),   "*g;H-Gaussian;");

  %% Stop?
  if pause_time > 0
    pause(pause_time);
  endif
endfunction

%% Do the recalls plot
function do_plot_recs(recs_fig, map_sort_idx, n_groups, truth, ...
                      pause_time)

  %% For each one
  plots = {};
  for c = 1 : n_groups
    %% Our truth
    o_truth = truth == c;

    %% Accumulated
    acc   = cumsum(o_truth(map_sort_idx));
    acc ./= acc(length(acc));

    %% Plot
    if c == 1
      plots = cell_push(plots, acc, "-r");
    else
      plots = cell_push(plots, acc, "-g");
    endif
  endfor

  %% Plot
  figure(recs_fig);
  plot(plots{:});

  %% Stop?
  if pause_time > 0
    pause(pause_time);
  endif
endfunction

%% Do the ROC plot
function do_roc_plot(window, sort_idx, s_truth, pause_time)

  %% ROC
  n_data = length(sort_idx);

  %% Find accumulated positive and negative
  roc_pos = cumsum( s_truth(sort_idx)); roc_pos ./= roc_pos(n_data);
  roc_neg = cumsum(~s_truth(sort_idx)); roc_neg ./= roc_neg(n_data);

  %% AUC
  auc = sum(diff(roc_neg) .* ...
            (roc_pos(1 : n_data - 1) + roc_pos(2 : n_data))) / 2;

  %% Plot
  figure(window);
  plot(roc_neg, roc_pos, sprintf("-;EWOCS(%.3f);", auc), ...
       [ 0, 1 ], [ 0, 1 ], "-;Random (0.5);");

  %% Stop?
  if pause_time > 0
    pause(pause_time);
  endif
endfunction


%%%%%%%%%%%%%%%%
%% Clusterers %%
%%%%%%%%%%%%%%%%

%% Kernel
switch cmd_opts.kernel
  case K_LINEAR
    kernel = LinearKernel();
  case K_POLYNOMIAL
    kernel = PolynomialKernel(cmd_opts.poly_degree, cmd_opts.poly_homogeneous);
  case K_RBF
    kernel = RBFKernel(cmd_opts.rbf_gamma);
endswitch

%% Distance
switch cmd_opts.distance
  case D_EUCLIDEAN
    distance = SqEuclideanDistance();
  case D_KERNEL
    distance = KernelDistance(kernel);
  case D_MAHALANOBIS
    distance = MahalanobisDistance(data);
endswitch

%% Clusterer
switch cmd_opts.clusterer
  case C_BERNOULLI
    clusterer = ...
        Bernoulli(struct("em_threshold",  cmd_opts.em_threshold, ...
                         "em_iterations", cmd_opts.em_iterations));
  case C_GAUSSIAN
    clusterer = ...
        Gaussian(struct("em_threshold",  cmd_opts.em_threshold, ...
                        "em_iterations", cmd_opts.em_iterations));
  case C_RANDOM
    clusterer = ...
        Random(struct("soft_alpha", cmd_opts.soft_alpha));
  case C_VORONOI
    clusterer = ...
        Voronoi(distance, struct("soft_alpha", cmd_opts.soft_alpha));
endswitch

%% Ewocs
ewocs = ...
    EWOCS(clusterer, struct("ensemble_size", cmd_opts.ensemble_size, ...
                            "min_clusters",  cmd_opts.min_clusters,  ...
                            "max_clusters",  cmd_opts.max_clusters));
                            %% "interpolator",  ClusterInterpolator()));

%%%%%%%%%%%%%%%
%% Same side %%
%%%%%%%%%%%%%%%

%% Do the same side task
function [ acc_prob, simp_acc_prob ] = ...
      do_same_side_one(clusterer, data, truth, cmd_opts, ...
                       truth_fig, expec_fig)

  %% Sizes
  n_data   = length(truth);
  n_groups = max(truth);

  %% Truth expectation
  t_expec = sparse(truth, 1 : n_data, ones(1, n_data), n_groups, n_data);

  %% Simplified expectation
  s_truth = truth > 1;
  s_expec = sparse(1 + s_truth, 1 : n_data, ones(1, n_data), 2, n_data);

  %% Sizes
  all_sizes  = full(sum(t_expec, 2))';
  pair_sizes = all_sizes' * all_sizes;

  %% Simplified sizes
  simp_all_sizes  = full(sum(s_expec, 2))';
  simp_pair_sizes = simp_all_sizes' * simp_all_sizes;

  %% Plot?
  if cmd_opts.do_plot
    do_plot_expec(truth_fig, data, t_expec, 0.0);
  endif

  %% Accumulated probs
  acc_prob      = zeros(n_groups, n_groups);
  simp_acc_prob = zeros(2, 2);

  %% For each inner run
  for ir = 1 : cmd_opts.inner_runs
    %% Number of clusters
    k = floor(cmd_opts.min_clusters + (cmd_opts.range_clusters + 1) * rand());

    %% Cluster it
    expec = cluster(clusterer, data, k);

    %% Harden it
    [ max_expec, max_cl ] = max(expec);
    h_expec = sparse(max_cl, 1 : n_data, ones(1, n_data), k, n_data);

    %% Plot?
    if cmd_opts.do_plot
      do_plot_expec(expec_fig, data, h_expec, cmd_opts.pause_time);
    endif

    %% Map
    mapped_expec = t_expec * h_expec';

    %%%% Count co-clustererd pairs
    pairs   = full(mapped_expec * mapped_expec');
    pairs ./= pair_sizes;

    %%%% Add to accumulated probabilities
    acc_prob += pairs;

    %% Simplified map
    simp_mapped_expec = s_expec * h_expec';

    %%%% Count co-clustererd pairs
    simp_pairs   = full(simp_mapped_expec * simp_mapped_expec');
    simp_pairs ./= simp_pair_sizes;

    %%%% Add to accumulated probabilities
    simp_acc_prob += simp_pairs;
  endfor

  %% Average results
  acc_prob      ./= cmd_opts.inner_runs;
  simp_acc_prob ./= cmd_opts.inner_runs;
endfunction

%% Do the same side task
function do_same_side(clusterer, cmd_args, cmd_opts)

  %% Create figures
  if cmd_opts.do_plot
    truth_fig = figure();
    expec_fig = figure();
  else
    truth_fig = 0;
    expec_fig = 0;
  endif

  %% Accumulated probs
  acc_prob      = zeros(1 + cmd_opts.signal_groups, ...
                        1 + cmd_opts.signal_groups);
  simp_acc_prob = zeros(2, 2);

  %% Arguments given?
  if length(cmd_args) == 0

    %% For each outer run
    for or = 1 : cmd_opts.outer_runs

      %% Generate the data
      [ data, truth ] = gen_data(cmd_opts);

      %% Do it
      [ prob, simp_prob ] = do_same_side_one(clusterer, data, truth, ...
                                             cmd_opts, truth_fig, expec_fig);

      %% Accumulate
      acc_prob      += prob;
      simp_acc_prob += simp_prob;
    endfor

    %% Average results
    acc_prob      ./= cmd_opts.outer_runs;
    simp_acc_prob ./= cmd_opts.outer_runs;

  else
    %% For each file
    for f = cmd_args

      %% Load
      if cmd_opts.sparse
        [ data, truth ] = read_sparse(f{1}, true());
      else
        load(f{1}, "data", "truth");
      endif

      %% Do it
      [ prob, simp_prob ] = do_same_side_one(clusterer, data, truth, ...
                                             cmd_opts, truth_fig, expec_fig);

      %% Accumulate
      acc_prob      += prob;
      simp_acc_prob += simp_prob;
    endfor

    %% Average results
    acc_prob      ./= length(cmd_args);
    simp_acc_prob ./= length(cmd_args);
  endif

  %% Display results
  acc_prob
  simp_acc_prob
endfunction


%%%%%%%%%%%%%%%%%%%%%
%% Score histogram %%
%%%%%%%%%%%%%%%%%%%%%

%% Do the score histogram task
function do_score_histo_one(ewocs, data, truth, cmd_opts, ...
                            truth_fig, expec_fig, mgauss_expec_fig, ...
                            score_fig, prc_rec_fig, recs_fig, dist_fig, ...
                            gauss_fig, gaussn_fig, mgauss_fig, hgauss_fig, ...
                            roc_fig);

  %% Sizes
  n_data   = length(truth);
  n_groups = max(truth);

  %% Truth expectation
  t_expec = sparse(truth, 1 : n_data, ones(1, n_data), n_groups, n_data);

  %% Simplified expectation
  s_truth = truth > 1;
  s_expec = sparse(1 + s_truth, 1 : n_data, ones(1, n_data),
                   2, n_data);

  %% Plot?
  if cmd_opts.do_plot
    do_plot_expec(truth_fig, data, t_expec, 0.0);
  endif

  %% For each inner run
  for ir = 1 : cmd_opts.inner_runs
    %% Run ewocs
    [ expec, model, info, scores ] = cluster(ewocs, data);

    %% Harden it
    h_expec = sparse(1 + (expec > 0.5), 1 : n_data, ones(1, n_data),
                     2, n_data);

    %% Plot?
    if cmd_opts.do_plot
      do_plot_expec(expec_fig, data, h_expec, 0.0);
      do_plot_score_data(score_fig, data, s_truth, scores, 0.0);
    endif

    %% Score plots
    [ histo_plots, max_histo ] = ...
        score_histo_plots(scores, t_expec, cmd_opts.histo_bins);

    %% Map scores
    map_scores = apply(LinearInterpolator(), scores);

    %% Sort
    [ sort_scores,     sort_idx     ] = sort(scores,     "descend");
    [ map_sort_scores, map_sort_idx ] = sort(map_scores, "descend");

    %% Prc/Rec curves
    [ prc, rec, f1 ] = prc_rec(map_sort_scores, map_sort_idx, s_truth);

    %% Plot each criterion
    [ min_knee_idx ] = do_plot_dist (dist_fig,  map_sort_scores, f1, 0.0);
    [ gauss_idx ]    = do_plot_gauss(gauss_fig, sort_scores, ...
                                     map_sort_scores, f1, ...
                                     histo_plots, max_histo, 0.0);
    [ gaussn_idx ]   = do_plot_gaussn(gaussn_fig, sort_scores, ...
                                      map_sort_scores, f1, ...
                                      histo_plots, max_histo, 0.0);
    [ mgauss_idx ]   = do_plot_mgauss(mgauss_fig, mgauss_expec_fig, ...
                                      data, sort_scores, sort_idx, ...
                                      map_sort_scores, f1, ...
                                      histo_plots, max_histo, 0.0);
    [ hgauss_idx ]   = do_plot_hgauss(hgauss_fig, sort_scores, ...
                                      map_sort_scores, f1, ...
                                      histo_plots, max_histo, 0.0);

    %% Plot the Prc/Rec and ROC
    do_plot_prc_rec(prc_rec_fig, map_sort_scores, prc, rec, f1, ...
                    min_knee_idx, gauss_idx, gaussn_idx, mgauss_idx, ...
                    hgauss_idx, 0.0);
    do_plot_recs(recs_fig, map_sort_idx, n_groups, truth, 0.0);
    do_roc_plot(roc_fig, sort_idx, s_truth, cmd_opts.pause_time);
  endfor
endfunction

%% Do the score histo task
function do_score_histo(ewocs, cmd_args, cmd_opts)

  %% Extra plot figures
  if cmd_opts.do_plot
    truth_fig        = figure("name", "Truth");
    expec_fig        = figure("name", "Output");
    score_fig        = figure("name", "Score");
    mgauss_expec_fig = figure("name", "M-Gaussian Output");
  else
    truth_fig        = 0;
    expec_fig        = 0;
    score_fig        = 0;
    mgauss_expec_fig = 0;
  endif

  %% Figures
  prc_rec_fig = figure("name", "Precision/Recall");
  recs_fig    = figure("name", "Recall");
  dist_fig    = figure("name", "Distance");
  gauss_fig   = figure("name", "2-Gaussian");
  gaussn_fig  = figure("name", "2-Gaussian/N");
  mgauss_fig  = figure("name", "M-Gaussian");
  hgauss_fig  = figure("name", "H-Gaussian");
  roc_fig     = figure("name", "ROC");

  %% Arguments given?
  if length(cmd_args) == 0

    %% For each outer run
    for or = 1 : cmd_opts.outer_runs

      %% Generate the data
      [ data, truth ] = gen_data(cmd_opts);

      %% Do it
      do_score_histo_one(ewocs, data, truth, cmd_opts, truth_fig, expec_fig, ...
                         mgauss_expec_fig, score_fig, prc_rec_fig, recs_fig, ...
                         dist_fig, gauss_fig, gaussn_fig, mgauss_fig, ...
                         hgauss_fig, roc_fig);
    endfor

  else
    %% For each file
    for f = cmd_args
      %% Load
      if cmd_opts.sparse
        [ data, truth ] = read_sparse(f{1}, true());
      else
        load(f{1}, "data", "truth");
      endif

      %% Do it
      do_score_histo_one(ewocs, data, truth, cmd_opts, truth_fig, expec_fig, ...
                         mgauss_expec_fig, score_fig, prc_rec_fig, recs_fig, ...
                         dist_fig, gauss_fig, gaussn_fig, mgauss_fig, ...
                         hgauss_fig, roc_fig);
    endfor
  endif
endfunction


%%%%%%%%%%%%
%% Do it! %%
%%%%%%%%%%%%

%% According to the task
switch cmd_opts.task
  case T_SAME_SIDE
    do_same_side(clusterer, cmd_args, cmd_opts)

  case T_SCORE_HISTO
    do_score_histo(ewocs, cmd_args, cmd_opts)
endswitch
