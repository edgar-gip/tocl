%% -*- mode: octave; -*-

%% Minority clustering of data

%% Author: Edgar Gonzàlez i Pellicer


%% Octopus
pkg load octopus


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
	   "kl", ...
	       KLDivergence(), ...
	   "mah",   @(data, extra) ...
	       MahalanobisDistance(data), ...
	   "rbf",   @(data, extra) ...
	       KernelDistance(RBFKernel(str2double(extra{1}))), ...
	   "rbf_g", @(data, extra) ...
	       KernelDistanceGenerator(RBFKernelGenerator(...
                   str2double(extra{1}),str2double(extra{2}))), ...
	   "skl",   @(data, extra) ...
	       SmoothKLDivergence(str2double(extra{1})), ...
	   "sqe", ...
	       SqEuclideanDistance());


%%%%%%%%%%%%%%%%
%% Thresholds %%
%%%%%%%%%%%%%%%%

%% Functions

%%%% Optimal
function [ th ] = th_best_f(sort_scores, sort_truth, msort_scores, ...
			    msort_model, f1_c, model)
  %% Best
  [ best_f1, best_idx ] = max(f1_c);
  th = sort_scores(best_idx);
endfunction

%%%% From model
function [ th ] = th_model_f(sort_scores, sort_truth, msort_scores, ...
			     msort_model, f1_c, model)
  th = threshold(model);
endfunction

%%% From size
function [ th ] = th_size_f(sort_scores, sort_truth, msort_scores, ...
			    msort_model, f1_c, model)
  th = sort_scores(round(length(sort_scores) * size_ratio(sort_truth)));
endfunction

%%%% From distance
function [ th ] = th_dist_f(sort_scores, sort_truth, msort_scores, ...
			    msort_model, f1_c, model)
  th = apply(DistanceKnee(), sort_scores);
endfunction

%%%% From 2 Gaussians
function [ th ] = th_gauss2_f(sort_scores, sort_truth, msort_scores, ...
			      msort_model, f1_c, model)
  th = apply(GaussianKnee(), sort_scores);
endfunction

%%%% From 2 Gaussians + Noise
function [ th ] = th_gauss2n_f(sort_scores, sort_truth, msort_scores, ...
			       msort_model, f1_c, model)
  th = apply(GaussianNoiseKnee(), sort_scores);
endfunction

%%%% From 2 Gaussians (Mapped)
function [ th ] = th_gauss2m_f(sort_scores, sort_truth, msort_scores, ...
			       msort_model, f1_c, model)
  th = inverse(msort_model, apply(GaussianKnee(), msort_scores));
endfunction

%%%% From 2 Gaussians + Noise (Mapped)
function [ th ] = th_gauss2nm_f(sort_scores, sort_truth, msort_scores, ...
				msort_model, f1_c, model)
  th = inverse(msort_model, apply(GaussianNoiseKnee(), msort_scores));
endfunction

%%%% From N Gaussians (Mapped)
function [ th ] = th_gaussNm_f(sort_scores, sort_truth, msort_scores, ...
			       msort_model, f1_c, model)
  %% Model
  [ expec, model ] = cluster(CriterionClusterer(Gaussian1D(), BIC(),  ...
						struct("max_k", 10)), ...
			     msort_scores);

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
    if ~isempty(cut_idx) && f1_c(cut_idx) > best_f1
      best_f1  = f1_c(cut_idx);
      best_c   = c;
      best_idx = cut_idx;
    endif
  endfor

  %% Best
  if best_idx == -1
    th = sort_scores(length(sort_scores));
  else
    th = sort_scores(best_idx);
  endif
endfunction

%%%% From N Gaussians + Noise (Mapped)
function [ th ] = th_gaussNnm_f(sort_scores, sort_truth, msort_scores, ...
				msort_model, f1_c, model)
  %% Model
  [ expec, model ] = cluster(CriterionClusterer(Gaussian1DNoise(), BIC(), ...
						struct("max_k", 10)),     ...
			     msort_scores);

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
    if ~isempty(cut_idx) && f1_c(cut_idx) > best_f1
      best_f1  = f1_c(cut_idx);
      best_c   = c;
      best_idx = cut_idx;
    endif
  endfor

  %% Best
  if best_idx == -1
    th = sort_scores(length(sort_scores));
  else
    th = sort_scores(best_idx);
  endif
endfunction

%% Objects
th_best     = struct("name", "Best",  "find", @th_best_f);
th_model    = struct("name", "Model", "find", @th_model_f);
th_size     = struct("name", "Size",  "find", @th_size_f);
th_dist     = struct("name", "Dist",  "find", @th_dist_f);
th_gauss2   = struct("name", "G-2",   "find", @th_gauss2_f);
th_gauss2n  = struct("name", "G-2N",  "find", @th_gauss2n_f);
th_gauss2m  = struct("name", "GM-2",  "find", @th_gauss2m_f);
th_gauss2nm = struct("name", "GM-2N", "find", @th_gauss2nm_f);
th_gaussNm  = struct("name", "GM-N",  "find", @th_gaussNm_f);
th_gaussNnm = struct("name", "GM-NN", "find", @th_gaussNnm_f);


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
		    th_gauss2m, th_gauss2nm, th_gaussNm, th_gaussNnm ]);
method_ewocs_voro_g = ...
    struct("make", @(dist, data, s_truth, extra) ...
	       EWOCS(GeneratedVoronoi(dist, struct("soft_alpha", 0.1)), ...
		     struct("ensemble_size", str2double(extra{1}), ...
			    "max_clusters", str2double(extra{2}), ...
			    "interpolator", "null")), ...
	   "ths", [ th_best, th_size, th_dist, th_gauss2, th_gauss2n, ...
		    th_gauss2m, th_gauss2nm, th_gaussNm, th_gaussNnm ]);
method_ewocs_bern = ...
    struct("make", @(dist, data, s_truth, extra) ...
	       EWOCS(Bernoulli(), ...
		     struct("ensemble_size", str2double(extra{1}), ...
			    "max_clusters", str2double(extra{2}), ...
			    "interpolator", "null")), ...
	   "ths", [ th_best, th_size, th_dist, th_gauss2, th_gauss2n, ...
		    th_gauss2m, th_gauss2nm, th_gaussNm, th_gaussNnm ]);
method_ewocs_kmeans = ...
    struct("make", @(dist, data, s_truth, extra) ...
	       EWOCS(KMeans(dist, struct("change_threshold", ...
					 str2double(extra{1}))), ...
		     struct("ensemble_size", str2double(extra{2}), ...
			    "max_clusters", str2double(extra{3}), ...
			    "interpolator", "null")), ...
	   "ths", [ th_best, th_size, th_dist, th_gauss2, th_gauss2n, ...
		    th_gauss2m, th_gauss2nm, th_gaussNm, th_gaussNnm ]);

%% Index
methods = ...
    struct("bbocc",        method_bbocc, ...
	   "bbcpress",     method_bbcpress, ...
	   "ewocs_voro",   method_ewocs_voro, ...
	   "ewocs_voro_g", method_ewocs_voro_g, ...
	   "ewocs_bern",   method_ewocs_bern, ...
	   "ewocs_kmeans", method_ewocs_kmeans);


%%%%%%%%%%
%% Main %%
%%%%%%%%%%

%% Get the parameters
args = argv();
if ~any(length(args) == [ 7, 8, 9 ])
  error(cstrcat("Wrong number of arguments: Expected", ...
		" <input> <distance> <d-extra> <method> <m-extra>", ...
		" <k> <seed> [<output> [<scores>]]"));
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

%% Output
if length(args) >= 8
  output = args{8};
  [ fout, status ] = fopen(output, "wt");
  if fout == -1
    error("Cannot open output '%s': %s", output, status);
  endif
else
  fout = 1;
endif


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

%% Map scores
[ msort_scores, msort_model ] = apply(LinearInterpolator(), sort_scores);

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
fprintf(fout, "*** %8g %5.3f ***\n", cluster_time, auc);

%% For each threshold
ths = getfield(methods, met, "ths");
for th = ths

  %% Find the threshold
  thfun    = getfield(th, "find");
  th_value = thfun(sort_scores, sort_truth, msort_scores, msort_model, ...
		   f1_c, model);

  %% Negative/positive cluster
  pos_cl = find(sort_scores >= th_value); n_pos_cl = length(pos_cl);
  neg_cl = find(sort_scores <  th_value);

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
  fprintf(fout, "%5s %5d  %5.3f %5.3f %5.3f %5.3f\n", ...
	  getfield(th, "name"), n_pos_cl, prc, rec, nrec, f1);
endfor

%% Close output
if fout ~= 1
  fclose(fout);
endif

%% Save?
if length(args) >= 9
  try
    save("-binary", "-zip", args{9}, "scores");
  catch
    error("Cannot save data to '%s': %s", args{9}, lasterr());
  end_try_catch
endif
