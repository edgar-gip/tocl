%% -*- mode: octave; -*-

%% Minority clustering of data

%% Author: Edgar Gonzàlez i Pellicer


%% Octopus
pkg load octopus


%%%%%%%%%%%
%% Plots %%
%%%%%%%%%%%

%% Histogram plot
function histogram_plot(sort_scores, sort_full, th_cuts)
  %% Histogram bins
  histo_bins = 100;

  %% Number of groups
  n_groups = max(sort_full);

  %% Min/max
  min_score = min(sort_scores);
  max_score = max(sort_scores);

  %% Histogram
  h = Histogram();

  %% Plots
  plots   = {};
  max_bin = 0;

  %% For each cl
  for cl = 1 : n_groups

    %% Cluster
    cluster = find(sort_full == cl);

    %% Histogram
    [ histo, bin_limits ] = ...
	make(h, sort_scores(cluster), histo_bins, min_score, max_score);

    %% Is it the noise cluster?
    if cl == 1
      plots = cell_push(plots, bin_limits, histo, "-r", "linewidth", 2);
    else
      plots = cell_push(plots, bin_limits, histo, "-");
    endif
  endfor

  %% All histogram
  [ histo, bin_limits ] = ...
      make(h, sort_scores, histo_bins, min_score, max_score);
  plots = cell_push(plots, bin_limits, histo, "-k", "linewidth", 2);

  %% Add thresholds
  for th = th_cuts
    %% Add the plot
    plots = cell_push(plots, ...
		      [ th.value ], [ 0 ], ...
		      sprintf("*;%s;", th.name), "linewidth", 4);
  endfor

  %% Plot
  figure("name", "Histogram");
  %% plot(plots{:});
  semilogy(plots{:});
endfunction

%% F1 plot
function f1_plot(sort_truth, sort_full, th_cuts)
  %% Find accumulated positive and negative
  cum_pos = cumsum( sort_truth);
  cum_neg = cumsum(~sort_truth);

  %% Length
  n_data = length(cum_pos);

  %% Precision
  prc = cum_pos ./ (cum_pos .+ cum_neg);
  rec = cum_pos ./ cum_pos(n_data);
  f1  = (2 .* prc .* rec) ./ (prc + rec);

  %% Remove NaN's
  f1(isnan(f1)) = 0.0;

  %% Plots
  plots = { 1 : n_data, prc, "-;Precision;", ...
	    1 : n_data, rec, "-;Recall;", ...
	    1 : n_data, f1,  "-;F1;" };

  %% Number of groups
  n_groups = max(sort_full);

  %% Cluster recall
  for cl = 1 : n_groups
    %% Find accumulated
    cum_cl = cumsum(sort_full == cl);
    cl_rec = cum_cl ./ cum_cl(n_data);

    %% Plot
    plots = cell_push(plots, ...
		      1 : n_data, cl_rec, ...
		      sprintf("-;Recall (%d);", cl));
  endfor

  %% Add thresholds
  for th = th_cuts
    %% Add the plot
    plots = cell_push(plots, ...
		      [ th.index ], [ f1(th.index) ], ...
		      sprintf("*;%s;", th.name), "linewidth", 4);
  endfor

  %% For
  figure("name", "Precision/Recall");
  plot(plots{:});
endfunction


%%%%%%%%%%%%%
%% Helpers %%
%%%%%%%%%%%%%

%% Size ratio
function [ ratio ] = size_ratio(s_truth)
  %% Find it
  ratio = sum(s_truth) / length(s_truth);
endfunction

%% Fields
function [ joint ] = fields(s)
  %% Field names
  names = strcat(fieldnames(s), ",");
  joint = strcat(names{:});
  joint = substr(joint, 1, length(joint) - 1);
endfunction


%%%%%%%%%%%%%%%
%% Distances %%
%%%%%%%%%%%%%%%

%% Distances
distances = ...
    struct("none", ...
	       [], ...
	   "sqe", ...
	       SqEuclideanDistance(),          ...
	   "rbf",   @(data, extra) ...
	       KernelDistance(RBFKernel(str2double(extra{1}))), ...
	   "rbf_g", @(data, extra) ...
	       KernelDistanceGenerator(RBFKernelGenerator(...
                   str2double(extra{1}),str2double(extra{2}))), ...
	   "mah",   @(data, extra) ...
	       MahalanobisDistance(data));


%%%%%%%%%%%%%%%%
%% Thresholds %%
%%%%%%%%%%%%%%%%

%% Functions

%%%% Optimal
function [ th ] = th_best_f(sort_scores, sort_truth, f1_c, model)
  %% Best
  [ best_f1, best_idx ] = max(f1_c);
  th = sort_scores(best_idx);
endfunction

%%%% From model
function [ th ] = th_model_f(sort_scores, sort_truth, f1_c, model)
  th = threshold(model);
endfunction

%%% From size
function [ th ] = th_size_f(sort_scores, sort_truth, f1_c, model)
  th = sort_scores(round(length(sort_scores) * size_ratio(sort_truth)));
endfunction

%%%% From distance
function [ th ] = th_dist_f(sort_scores, sort_truth, f1_c, model)
  th = apply(DistanceKnee(), sort_scores);
endfunction

%%%% From 2 Gaussians
function [ th ] = th_gauss2_f(sort_scores, sort_truth, f1_c, model)
  th = apply(GaussianKnee(), sort_scores);
endfunction

%%%% From 2 Gaussians + Noise
function [ th ] = th_gauss2n_f(sort_scores, sort_truth, f1_c, model)
  th = apply(GaussianNoiseKnee(), sort_scores);
endfunction

%%%% From N Gaussians
function [ th ] = th_gaussN_f(sort_scores, sort_truth, f1_c, model)
  %% Model
  [ expec, model ] = cluster(CriterionClusterer(Gaussian1D(), BIC(),  ...
						struct("max_k", 10)), ...
			     sort_scores);

  %% Sort the clusters
  model
  [ sorted_mns, sorted_cl ] = sort(means(model), "descend");

  %% Plots, and best cut point
  best_f1  = 0.0;
  best_c   = -1;
  best_idx = -1;

  %% Find it
  for c = 1 : length(sorted_cl) - 1

    %% Expec
    expec_tru = sum(expec(sorted_cl(1 : c), :), 1);
    cut_idx   = max(find(expec_tru >= 0.5));

    %% Better?
    if f1_c(cut_idx) > best_f1
      best_f1  = f1_c(cut_idx);
      best_c   = c;
      best_idx = cut_idx;
    endif
  endfor

  %% Best
  th = sort_scores(best_idx);
endfunction

%%%% From N Gaussians + Noise
function [ th ] = th_gaussNn_f(sort_scores, sort_truth, f1_c, model)
  %% Model
  [ expec, model ] = cluster(CriterionClusterer(Gaussian1DNoise(), BIC(), ...
						struct("max_k", 10)),     ...
			     sort_scores);

  %% Sort the clusters
  [ sorted_mns, sorted_cl ] = sort(means(model), "descend");

  %% Plots, and best cut point
  best_f1  = 0.0;
  best_c   = -1;
  best_idx = -1;

  %% Find it
  for c = 1 : length(sorted_cl) - 1

    %% Expec
    expec_tru = sum(expec(sorted_cl(1 : c), :), 1);
    cut_idx   = max(find(expec_tru >= 0.5));

    %% Better?
    if f1_c(cut_idx) > best_f1
      best_f1  = f1_c(cut_idx);
      best_c   = c;
      best_idx = cut_idx;
    endif
  endfor

  %% Best
  th = sort_scores(best_idx);
endfunction

%% Objects
th_best    = struct("name", "Best",  "find", @th_best_f);
th_model   = struct("name", "Model", "find", @th_model_f);
th_size    = struct("name", "Size",  "find", @th_size_f);
th_dist    = struct("name", "Dist",  "find", @th_dist_f);
th_gauss2  = struct("name", "G-2",   "find", @th_gauss2_f);
th_gauss2n = struct("name", "G-2N",  "find", @th_gauss2n_f);
th_gaussN  = struct("name", "G-N",   "find", @th_gaussN_f);
th_gaussNn = struct("name", "G-NN",  "find", @th_gaussNn_f);


%%%%%%%%%%%%%
%% Methods %%
%%%%%%%%%%%%%

%% Objects
method_bbocc = ...
    struct("make", @(dist, data, s_truth, extra) ...
	       BBOCC(dist, struct("size_ratio", size_ratio(s_truth))), ...
	   "ths", [ th_best, th_model, th_size ]);
method_bbcpress = ...
    struct("make", @(dist, data, s_truth, extra) ...
	       BBCPress(dist, struct("size_ratio", size_ratio(s_truth))), ...
	   "ths", [ th_best, th_model, th_size ]);
method_ewocs_voro = ...
    struct("make", @(dist, data, s_truth, extra) ...
	       EWOCS(Voronoi(dist, struct("soft_alpha", 0.1)), ...
		     struct("ensemble_size", str2double(extra{1}), ...
			    "max_clusters", str2double(extra{2}), ...
			    "interpolator", "null")), ...
	   "ths", [ th_best, th_size, th_dist, th_gauss2, th_gauss2n, ...
		    th_gaussN, th_gaussNn ]);
method_ewocs_voro_g = ...
    struct("make", @(dist, data, s_truth, extra) ...
	       EWOCS(GeneratedVoronoi(dist, struct("soft_alpha", 0.1)), ...
		     struct("ensemble_size", str2double(extra{1}), ...
			    "max_clusters", str2double(extra{2}), ...
			    "interpolator", "null")), ...
	   "ths", [ th_best, th_size, th_dist, th_gauss2, th_gauss2n, ...
		    th_gaussN, th_gaussNn ]);
method_ewocs_bern = ...
    struct("make", @(dist, data, s_truth, extra) ...
	       EWOCS(Bernoulli(), ...
		     struct("ensemble_size", str2double(extra{1}), ...
			    "max_clusters", str2double(extra{2}), ...
			    "interpolator", "null")), ...
	   "ths", [ th_best, th_size, th_dist, th_gauss2, th_gauss2n, ...
		    th_gaussN, th_gaussNn ]);

%% Index
methods = ...
    struct("bbocc",        method_bbocc, ...
	   "bbcpress",     method_bbcpress, ...
	   "ewocs_voro",   method_ewocs_voro, ...
	   "ewocs_voro_g", method_ewocs_voro_g, ...
	   "ewocs_bern",   method_ewocs_bern);


%%%%%%%%%%
%% Main %%
%%%%%%%%%%

%% Get the parameters
args = argv();
if length(args) ~= 7
  error(cstrcat("Wrong number of arguments: Expected", ...
		" <input> <distance> <d-extra> <method> <m-extra>", ...
		" <k> <seed>"));
endif

%% Input file
input = args{1};
try
  load(input, "data", "truth");
catch
  error("Cannot load data from '%s': %s", input, lasterr());
end_try_catch

%% Distance
dist = args{2};
if ~isfield(distances, dist)
  error("Wrong distance name '%s'. Must be: %s", met, fields(distances));
endif

%% Extra arguments
dextra = regex_split(args{3}, '(,|\s+,)\s*');

%% Method
met = args{4};
if ~isfield(methods, met)
  error("Wrong method name '%s'. Must be: %s", met, fields(methods));
endif

%% Extra arguments
mextra = regex_split(args{5}, '(,|\s+,)\s*');

%% k
[ k, status ] = str2double(args{6});
if status ~= 0
  error("Wrong number of clusters '%s'", args{6})
endif

%% Seed
[ seed, status ] = str2double(args{7});
if status ~= 0
  error("Wrong seed '%s'", args{7});
endif


%% Plot data
pairwise_cluster_plot(data, truth, "Truth");

%% Initialize seed
set_all_seeds(seed);

%% Create distance
distfun = getfield(distances, dist);
if isfunctionhandle(distfun)
  distance = distfun(data, dextra);
else
  distance = distfun;
endif

%% Truth information
n_data  = length(truth);
s_truth = truth > 1;

%% Create clusterer
clustfun  = getfield(methods, met, "make");
clusterer = clustfun(distance, data, s_truth, mextra);

%% Cluster
[ total0, user0, system0 ] = cputime();
[ expec, model ] = cluster(clusterer, data, k);
[ total1, user1, system1 ] = cputime();

%% Time difference
cluster_time = total1 - total0;


%% Sort by score
scores = score(model, data);
[ sort_scores, sort_idx ] = sort(scores, "descend");
sort_truth = s_truth(sort_idx);
sort_full  = truth(sort_idx);

%% Range
range = sort_scores(length(sort_scores)) - sort_scores(1)

%% Truth classes
pos_tr  = find( sort_truth); n_pos_tr = length(pos_tr);
neg_tr  = find(~sort_truth); n_neg_tr = length(neg_tr);

%% ROC

%% Find accumulated positive and negative
acc_pos = cumsum( sort_truth);
acc_neg = cumsum(~sort_truth);

%% Find ROC
roc_pos = acc_pos ./ n_pos_tr;
roc_neg = acc_neg ./ n_neg_tr;

%% AUC
auc = sum(diff(roc_neg) .* ...
	  (roc_pos(1 : n_data - 1) + roc_pos(2 : n_data))) / 2;

%% Prc/Rec/F1 curves
prc_c = acc_pos ./ (acc_pos .+ acc_neg);
rec_c = acc_pos ./  acc_pos(n_data);
f1_c  = (2 .* prc_c .* rec_c) ./ (prc_c .+ rec_c);

%% Display
printf("*** %8g %5.3f ***\n", cluster_time, auc);


%% Threshold cut points
th_cuts = struct();

%% For each threshold
i   = 1;
ths = getfield(methods, met, "ths");
for th = ths

  %% Find the threshold
  thfun    = getfield(th, "find");
  th_value = thfun(sort_scores, sort_truth, f1_c, model);

  %% Negative/positive cluster
  pos_cl = find(sort_scores >= th_value); n_pos_cl = length(pos_cl);
  neg_cl = find(sort_scores <  th_value);

  %% Set
  th_cuts(i).name  = th.name;
  th_cuts(i).value = th_value;
  th_cuts(i).index = max(pos_cl);

  %% Intersections
  pos_pos = intersect(pos_tr, pos_cl);
  pos_neg = intersect(pos_tr, neg_cl);
  neg_pos = intersect(neg_tr, pos_cl);
  neg_neg = intersect(neg_tr, neg_cl);

  %% Sizes
  n_pos_pos = length(pos_pos);
  n_pos_neg = length(pos_neg);
  n_neg_pos = length(neg_pos);
  n_neg_neg = length(neg_neg);

  %% Precision/Recall
  prc  = n_pos_pos / (n_pos_pos + n_neg_pos);
  rec  = n_pos_pos / (n_pos_pos + n_pos_neg);
  nrec = n_neg_pos / (n_neg_pos + n_neg_neg);
  f1   = 2 * prc * rec / (prc + rec);

  %% Output

  %% Display
  printf("%5s %5d  %5.3f %5.3f %5.3f %5.3f\n", ...
	 getfield(th, "name"), n_pos_cl, prc, rec, nrec, f1);

  %% Plot data
  th_truth = 1 + (scores >= th_value);
  pairwise_cluster_plot(data, th_truth, th.name);

  %% Next
  i += 1;
endfor

%% Histogram plot
histogram_plot(sort_scores, sort_full, th_cuts);

%% F1 plot
f1_plot(sort_truth, sort_full, th_cuts);

%% Pause
pause();
