%% -*- mode: octave; -*-

%% Elements

%% Author: Edgar Gonz�lez i Pellicer


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
	       EWOCS(KMeans(dist, struct("change_threshold", 0.1)), ...
		     struct("ensemble_size", str2double(extra{1}), ...
			    "max_clusters", str2double(extra{2}), ...
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
