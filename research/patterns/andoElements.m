%% -*- mode: octave; -*-

%% Elements

%% Author: Edgar Gonzàlez i Pellicer


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


%%%%%%%%%%%%%%%%%%%%
%% n-Gauss Models %%
%%%%%%%%%%%%%%%%%%%%

%% n-Gauss
function [ expec, model ] = gaussNm(msort_scores)
  %% Cache
  persistent cached_expec = [];
  persistent cached_model = [];

  %% Fill the cache?
  if isempty(cached_model)
    [ cached_expec, cached_model ] = ...
	cluster(CriterionClusterer(Gaussian1D(), BIC(),  ...
				   struct("max_k",  10, ...
					  "repeats", 1)), ...
		msort_scores);
  endif

  %% Access it
  expec = cached_expec;
  model = cached_model;
endfunction

%% n-Gauss + Noise
function [ expec, model ] = gaussSm(msort_scores)
  %% Cache
  persistent cached_expec = [];
  persistent cached_model = [];

  %% Fill the cache?
  if isempty(cached_model)
    [ cached_expec, cached_model ] = ...
	cluster(CriterionClusterer(Gaussian1DNoise(), BIC(),  ...
				   struct("max_k",  10, ...
					  "repeats", 1)), ...
		msort_scores);
  endif

  %% Access it
  expec = cached_expec;
  model = cached_model;
endfunction


%%%%%%%%%%%%%%%%%%%%%
%% n-Gauss Cutoffs %%
%%%%%%%%%%%%%%%%%%%%%

%% * + Best
function [ th ] = gaussN_best(expec, model, sort_scores, f1_c)
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
    cut_idx   = last_downfall(expec_tru, 0.5);

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

%% * + Dist
function [ th ] = gaussN_dist(expec, model, sort_scores, msort_scores)
  %% Sort the clusters
  [ sorted_mns, sorted_cl ] = sort(means(model), "descend");

  %% Size
  n_data = length(sort_scores);

  %% Plots, and best cut point
  best_dist = inf;
  best_c    =  -1;
  best_idx  =  -1;

  %% Find it
  for c = 1 : length(sorted_cl) - 1
    %% Expec
    expec_tru = sum(expec(sorted_cl(1 : c), :), 1);
    cut_idx   = last_downfall(expec_tru, 0.5);

    %% Not empty?
    if ~isempty(cut_idx)
      %% Distance
      dist = ((cut_idx - 1) / (n_data - 1)) .^ 2 + msort_scores(cut_idx) .^ 2;

      %% Smaller?
      if dist < best_dist
	best_dist = dist;
	best_c    = c;
	best_idx  = cut_idx;
      endif
    endif
  endfor

  %% Best
  if best_idx == -1
    th = sort_scores(length(sort_scores));
  else
    th = sort_scores(best_idx);
  endif
endfunction

%% * + 2-BIC
function [ th ] = gaussN_bic2(expec, model, sort_scores, msort_scores)
  %% Sort the clusters
  [ sorted_mns, sorted_cl ] = sort(means(model), "descend");
  k = length(sorted_cl);

  %% Plots, and best cut point
  best_bic  = -inf;
  best_c    =   -1;
  best_idx  =   -1;

  %% Find it
  for c = 1 : k - 1
    %% Map expectation (1 .. c -> 1, (c + 1) .. k -> 2)
    map    = sparse([ 1 * ones(1, c), 2 * ones(1, k - c) ], sorted_cl, ...
		    ones(1, k), 2, k);
    mexpec = map * expec;

    %% Model and expectation
    [ model_2 ]             = maximization(Gaussian1D(), msort_scores, mexpec);
    [ expec_2, log_like_2 ] = expectation(model_2, msort_scores);

    %% BIC!
    [ bic ] = apply(BIC(), msort_scores, expec_2, model_2, log_like_2);

    %% Better?
    if bic > best_bic
      %% Cut point
      expec_tru = expec_2(1, :);
      cut_idx   = last_downfall(expec_tru, 0.5);

      %% Empty?
      if ~isempty(cut_idx)
	best_bic = bic;
	best_c   = c;
	best_idx = cut_idx;
      endif
    endif
  endfor

  %% Best
  if best_idx == -1
    th = sort_scores(length(sort_scores));
  else
    th = sort_scores(best_idx);
  endif
endfunction

%% * + n-BIC
function [ th ] = gaussN_bicN(expec, model, sort_scores, msort_scores)
  %% Sort the clusters
  [ sorted_mns, sorted_cl ] = sort(means(model), "descend");
  k = length(sorted_cl);

  %% Plots, and best cut point
  best_bic  = -inf;
  best_c    =   -1;
  best_idx  =   -1;

  %% Find it
  for c = 1 : k - 1
    %% Map expectation (1 .. c -> 1 .. c, (c + 1) .. k -> c + 1)
    map    = sparse([ 1 : c, (c + 1) * ones(1, k - c) ], sorted_cl, ...
		    ones(1, k), c + 1, k);
    mexpec = map * expec;

    %% Model and expectation
    [ model_2 ]             = maximization(Gaussian1D(), msort_scores, mexpec);
    [ expec_2, log_like_2 ] = expectation(model_2, msort_scores);

    %% BIC!
    [ bic ] = apply(BIC(), msort_scores, expec_2, model_2, log_like_2);

    %% Better?
    if bic > best_bic
      %% Cut point
      expec_tru = sum(expec_2(1 : c, :), 1);
      cut_idx   = last_downfall(expec_tru, 0.5);

      %% Empty?
      if ~isempty(cut_idx)
	best_bic = bic;
	best_c   = c;
	best_idx = cut_idx;
      endif
    endif
  endfor

  %% Best
  if best_idx == -1
    th = sort_scores(length(sort_scores));
  else
    th = sort_scores(best_idx);
  endif
endfunction

%% * + Var
function [ th ] = gaussN_var(expec, model, sort_scores, msort_scores)
  %% Sort the clusters
  [ sorted_mns, sorted_cl ] = sort(means(model), "descend");
  [ sorted_vars ]           = variances(model)(sorted_cl);
  k = length(sorted_cl);

  %% Plots, and best cut point
  best_diff = -inf;
  best_c    =   -1;
  best_idx  =   -1;

  %% Find it
  for c = 1 : k - 1
    %% Left and right variances
    lvar = mean(sorted_vars(1 : c));
    rvar = mean(sorted_vars(c + 1 : k));
    diff = abs(lvar - rvar);

    %% Difference
    if diff > best_diff
      %% Expec
      expec_tru = sum(expec(sorted_cl(1 : c), :), 1);
      cut_idx   = last_downfall(expec_tru, 0.5);

      %% Better?
      if ~isempty(cut_idx)
	best_diff = diff;
	best_c    = c;
	best_idx  = cut_idx;
      endif
    endif
  endfor

  %% Best
  if best_idx == -1
    th = sort_scores(length(sort_scores));
  else
    th = sort_scores(best_idx);
  endif
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

%%%% All
function [ th ] = th_all_f(sort_scores, sort_truth, msort_scores, ...
			   msort_model, f1_c, model)
  %% All
  th = sort_scores(length(sort_scores));
endfunction

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
  [ expec, model ] = gaussNm(msort_scores);

  %% Best
  [ th ] = gaussN_best(expec, model, sort_scores, f1_c);
endfunction

%%%% From N Gaussians (Mapped) -> Select smaller distance
function [ th ] = th_gaussNm_dist_f(sort_scores, sort_truth, msort_scores, ...
				    msort_model, f1_c, model)
  %% Model
  [ expec, model ] = gaussNm(msort_scores);

  %% Dist
  [ th ] = gaussN_dist(expec, model, sort_scores, msort_scores);
endfunction

%%%% From N Gaussians (Mapped) -> 2-BIC
function [ th ] = th_gaussNm_bic2_f(sort_scores, sort_truth, msort_scores, ...
				    msort_model, f1_c, model)
  %% Model
  [ expec, model ] = gaussNm(msort_scores);

  %% Dist
  [ th ] = gaussN_bic2(expec, model, sort_scores, msort_scores);
endfunction

%%%% From N Gaussians (Mapped) -> n-BIC
function [ th ] = th_gaussNm_bicN_f(sort_scores, sort_truth, msort_scores, ...
				    msort_model, f1_c, model)
  %% Model
  [ expec, model ] = gaussNm(msort_scores);

  %% Dist
  [ th ] = gaussN_bicN(expec, model, sort_scores, msort_scores);
endfunction

%%%% From N Gaussians (Mapped) -> Var
function [ th ] = th_gaussNm_var_f(sort_scores, sort_truth, msort_scores, ...
				   msort_model, f1_c, model)
  %% Model
  [ expec, model ] = gaussNm(msort_scores);

  %% Dist
  [ th ] = gaussN_var(expec, model, sort_scores, msort_scores);
endfunction

%%%% From N Gaussians + Noise (Mapped)
function [ th ] = th_gaussNnm_f(sort_scores, sort_truth, msort_scores, ...
				msort_model, f1_c, model)
  %% Model
  [ expec, model ] = gaussSm(msort_scores);

  %% Best
  [ th ] = gaussN_best(expec, model, sort_scores, f1_c);
endfunction

%%%% From N Gaussians + Noise (Mapped) -> Select smaller distance
function [ th ] = th_gaussNnm_dist_f(sort_scores, sort_truth, msort_scores, ...
				     msort_model, f1_c, model)
  %% Model
  [ expec, model ] = gaussSm(msort_scores);

  %% Dist
  [ th ] = gaussN_dist(expec, model, sort_scores, msort_scores);
endfunction

%% Objects
th_all           = struct("name", "All",     "find", @th_all_f,           ...
			  "level", 1);
th_best          = struct("name", "Best",    "find", @th_best_f,          ...
			  "level", 1);
th_model         = struct("name", "Model",   "find", @th_model_f,         ...
			  "level", 1);
th_size          = struct("name", "Size",    "find", @th_size_f,          ...
			  "level", 1);
th_dist          = struct("name", "Dist",    "find", @th_dist_f,          ...
			  "level", 1);
th_gauss2        = struct("name", "G-2",     "find", @th_gauss2_f,        ...
			  "level", 3);
th_gauss2n       = struct("name", "G-2N",    "find", @th_gauss2n_f,       ...
			  "level", 3);
th_gauss2m       = struct("name", "GM-2",    "find", @th_gauss2m_f,       ...
			  "level", 1);
th_gauss2nm      = struct("name", "GM-2N",   "find", @th_gauss2nm_f,      ...
			  "level", 2);
th_gaussNm       = struct("name", "GM-N",    "find", @th_gaussNm_f,       ...
			  "level", 2);
th_gaussNm_dist  = struct("name", "GM-N-D",  "find", @th_gaussNm_dist_f,  ...
			  "level", 2);
th_gaussNm_bic2  = struct("name", "GM-N-B2", "find", @th_gaussNm_bic2_f,  ...
			  "level", 2);
th_gaussNm_bicN  = struct("name", "GM-N-BN", "find", @th_gaussNm_bicN_f,  ...
			  "level", 2);
th_gaussNm_var   = struct("name", "GM-N-V",  "find", @th_gaussNm_var_f,  ...
			  "level", 2);
th_gaussNnm      = struct("name", "GM-NN",   "find", @th_gaussNnm_f,      ...
			  "level", 3);
th_gaussNnm_dist = struct("name", "GM-NN-D", "find", @th_gaussNnm_dist_f, ...
			  "level", 3);


%% Threshold sets
ths_simple = [ th_all, th_best, th_model, th_size ];
ths_ewocs  = [ th_all, th_best, th_size, th_dist, ...
	       th_gauss2, th_gauss2n, th_gauss2m, th_gauss2nm, ...
	       th_gaussNm, th_gaussNm_dist, ...
	       th_gaussNm_bic2, th_gaussNm_bicN, th_gaussNm_var, ...
	       th_gaussNnm, th_gaussNnm_dist ];


%%%%%%%%%%%%%
%% Methods %%
%%%%%%%%%%%%%

%% Objects
method_bbocc = ...
    struct("args", 0, ...
	   "help", "", ...
	   "make", @(dist, data, s_truth, extra) ...
	       BBOCC(dist, struct("size_ratio", size_ratio(s_truth))), ...
	   "ths",  ths_simple);
method_bbcpress = ...
    struct("args", 0, ...
	   "help", "", ...
	   "make", @(dist, data, s_truth, extra) ...
	       BBCPress(dist, struct("size_ratio", size_ratio(s_truth))), ...
	   "ths",  ths_simple);
method_ewocs_bern = ...
    struct("args", 2, ...
	   "help", "<ensemble_size>, <max_clusters>", ...
	   "make", @(dist, data, s_truth, extra) ...
	       EWOCS(Bernoulli(), ...
		     struct("ensemble_size", str2double(extra{1}), ...
			    "max_clusters", str2double(extra{2}), ...
			    "interpolator", "null")), ...
	   "ths", ths_ewocs);
method_ewocs_hproj = ...
    struct("args", 2, ...
	   "help", "<ensemble_size>, <max_clusters>", ...
	   "make", @(dist, data, s_truth, extra) ...
	   EWOCS(RandomProj(struct("soft_alpha", nan,
				   "homogeneous", true())), ...
		 struct("ensemble_size", str2double(extra{1}), ...
			"max_clusters", str2double(extra{2}), ...
			"interpolator", "null")), ...
	   "ths", ths_ewocs);
method_ewocs_hvoro = ...
    struct("args", 2, ...
	   "help", "<ensemble_size>, <max_clusters>", ...
	   "make", @(dist, data, s_truth, extra) ...
           EWOCS(Voronoi(dist, struct("soft_alpha", nan)), ...
                 struct("ensemble_size", str2double(extra{1}), ...
                        "max_clusters", str2double(extra{2}), ...
                        "interpolator", "null")), ...
	   "ths", ths_ewocs);
method_ewocs_kmeans = ...
    struct("args", 2, ...
	   "help", "<ensemble_size>, <max_clusters>", ...
	   "make", @(dist, data, s_truth, extra) ...
	   EWOCS(KMeans(dist, struct("change_threshold", 0.1)), ...
		 struct("ensemble_size", str2double(extra{1}), ...
			"max_clusters", str2double(extra{2}), ...
			"interpolator", "null")), ...
	   "ths", ths_ewocs);
method_ewocs_rproj = ...
    struct("args", 2, ...
	   "help", "<ensemble_size>, <max_clusters>", ...
	   "make", @(dist, data, s_truth, extra) ...
	   EWOCS(RandomProj(struct("soft_alpha", nan)), ...
		 struct("ensemble_size", str2double(extra{1}), ...
			"max_clusters", str2double(extra{2}), ...
			"interpolator", "null")), ...
	   "ths", ths_ewocs);
method_ewocs_voro = ...
    struct("args", 2, ...
	   "help", "<ensemble_size>, <max_clusters>", ...
	   "make", @(dist, data, s_truth, extra) ...
           EWOCS(Voronoi(dist, struct("soft_alpha", 0.1)), ...
                 struct("ensemble_size", str2double(extra{1}), ...
                        "max_clusters", str2double(extra{2}), ...
                        "interpolator", "null")), ...
	   "ths", ths_ewocs);
method_ewocs_voro_g = ...
    struct("args", 2, ...
	   "help", "<ensemble_size>, <max_clusters>", ...
	   "make", @(dist, data, s_truth, extra) ...
	   EWOCS(GeneratedVoronoi(dist, struct("soft_alpha", 0.1)), ...
		 struct("ensemble_size", str2double(extra{1}), ...
			"max_clusters", str2double(extra{2}), ...
			"interpolator", "null")), ...
	   "ths", ths_ewocs);

%% Index
methods = ...
    struct("bbocc",        method_bbocc, ...
	   "bbcpress",     method_bbcpress, ...
	   "ewocs_bern",   method_ewocs_bern, ...
	   "ewocs_hproj",  method_ewocs_hproj, ...
	   "ewocs_hvoro",  method_ewocs_hvoro, ...
	   "ewocs_kmeans", method_ewocs_kmeans, ...
	   "ewocs_rproj",  method_ewocs_rproj, ...
	   "ewocs_voro",   method_ewocs_voro, ...
	   "ewocs_voro_g", method_ewocs_voro_g);
