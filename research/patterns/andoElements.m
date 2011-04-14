%% -*- mode: octave; -*-

%% Elements

%% Author: Edgar Gonzàlez i Pellicer


%%%%%%%%%%%%%
%% Helpers %%
%%%%%%%%%%%%%

%% Size ratio
function [ ratio ] = size_ratio(struth)
  %% Find it
  ratio = sum(struth) / length(struth);
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
    %% Model
    [ raw_expec, raw_model ] = ...
	cluster(CriterionClusterer(Gaussian1D(), BIC(),  ...
				   struct("max_k",  10, ...
					  "repeats", 1)), ...
		msort_scores);

    %% Sort the model
    [ cached_model, sorted_cl ] = sort_means(raw_model, "descend");

    %% Sort the expectation
    cached_expec = raw_expec(sorted_cl, :);
  endif

  %% Access it
  expec = cached_expec;
  model = cached_model;
endfunction

%% 3 * n-Gauss
function [ expec, model ] = gaussN3(msort_scores, sort_data)
  %% Cache
  persistent cached_expec = [];
  persistent cached_model = [];

  %% Fill the cache?
  if isempty(cached_model)
    %% Inner clusterer
    inner = SeqEM({ Gaussian1D(), Gaussian() }, struct("final_model", 1));

    %% Model
    [ raw_expec, raw_model ] = ...
	cluster(CriterionClusterer(inner, BIC(),  ...
				   struct("max_k",  10, ...
					  "repeats", 1)), ...
		msort_scores);

    %% Sort the model
    [ cached_model, sorted_cl ] = sort_means(raw_model, "descend");

    %% Sort the expectation
    cached_expec = raw_expec(sorted_cl, :);
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
    %% Model
    [ raw_expec, raw_model ] = ...
	cluster(CriterionClusterer(Gaussian1DNoise(), BIC(),  ...
				   struct("max_k",  10, ...
					  "repeats", 1)), ...
		msort_scores);

    %% Sort the model
    [ cached_model, sorted_cl ] = sort_means(raw_model, "descend");

    %% Sort the expectation
    cached_expec = raw_expec(sorted_cl, :);
  endif

  %% Access it
  expec = cached_expec;
  model = cached_model;
endfunction


%%%%%%%%%%%%%%%%%%%%
%% n-Gauss Models %%
%%%%%%%%%%%%%%%%%%%%

%% n-Gauss Heterogeneousness
function [ c_hetero, l_hetero, r_hetero ] = gaussNm_hetero(sort_data, expec)
  %% Initialize
  persistent cached_c_hetero = [];
  persistent cached_l_hetero = [];
  persistent cached_r_hetero = [];

  %% Fill the cache?
  if isempty(cached_c_hetero)
    %% Size
    [ n_groups, n_data ] = size(expec);

    %% Class
    [ best_expec, best_cl ] = max(expec);

    %% Reset
    cached_c_hetero = zeros(1, n_groups);
    cached_l_hetero = zeros(1, n_groups);
    cached_r_hetero = zeros(1, n_groups);

    %% For each one
    for cl = 1 : n_groups
      %% Find the trace of the covariance matrix
      %% i.e., the sum of variances

      %% The cluster
      idx = find(best_cl == cl);
      if ~isempty(idx)
	cached_c_hetero(cl) = sum(var(sort_data(:, idx)'));
      else
	cached_c_hetero(cl) = nan;
      endif

      %% Left side
      lidx = find(best_cl <= cl);
      if ~isempty(lidx)
	cached_l_hetero(cl) = sum(var(sort_data(:, lidx)'));
      else
	cached_l_hetero(cl) = nan;
      endif

      %% Right side
      ridx = find(best_cl >= cl);
      if ~isempty(ridx)
	cached_r_hetero(cl) = sum(var(sort_data(:, ridx)'));
      else
	cached_r_hetero(cl) = nan;
      endif
    endfor
  endif

  %% Access it
  c_hetero = cached_c_hetero;
  l_hetero = cached_l_hetero;
  r_hetero = cached_r_hetero;
endfunction


%%%%%%%%%%%%%%%%%%%%%
%% n-Gauss Cutoffs %%
%%%%%%%%%%%%%%%%%%%%%

%% * + Best
function [ th ] = gaussN_best(expec, model, sort_scores, f1_c)
  %% Size
  [ k, n_data ] = size(expec);

  %% Plots, and best cut point
  best_f1  = 0.0;
  best_c   = -1;
  best_idx = -1;

  %% Find it
  for c = 1 : k - 1

    %% Expec
    expec_tru = sum(expec(1 : c, :), 1);
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
  %% Size
  [ k, n_data ] = size(expec);

  %% Size
  n_data = length(sort_scores);

  %% Plots, and best cut point
  best_dist = inf;
  best_c    =  -1;
  best_idx  =  -1;

  %% Find it
  for c = 1 : k - 1
    %% Expec
    expec_tru = sum(expec(1 : c, :), 1);
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
  %% Size
  [ k, n_data ] = size(expec);

  %% Plots, and best cut point
  best_bic  = -inf;
  best_c    =   -1;
  best_idx  =   -1;

  %% Find it
  for c = 1 : k - 1
    %% Map expectation (1 .. c -> 1, (c + 1) .. k -> 2)
    map    = sparse([ 1 * ones(1, c), 2 * ones(1, k - c) ], 1 : k, ...
		    ones(1, k), 2, k);
    mexpec = map * expec;

    %% Model and expectation
    [ model_2 ]             = maximization(Gaussian1D(), msort_scores, mexpec);
    [ expec_2, log_like_2 ] = expectation(model_2, msort_scores);

    %% BIC!
    [ bic ] = apply(BIC(), msort_scores, expec_2, model_2, log_like_2);

    %% Better?
    if bic > best_bic
      %% Expec
      expec_tru = sum(expec(1 : c, :), 1);
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

%% * + 2-BIC (Recalculate)
function [ th ] = gaussN_bic2r(expec, model, sort_scores, msort_scores)
  %% Size
  [ k, n_data ] = size(expec);

  %% Plots, and best cut point
  best_bic  = -inf;
  best_c    =   -1;
  best_idx  =   -1;

  %% Find it
  for c = 1 : k - 1
    %% Map expectation (1 .. c -> 1, (c + 1) .. k -> 2)
    map    = sparse([ 1 * ones(1, c), 2 * ones(1, k - c) ], 1 : k, ...
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
  %% Size
  [ k, n_data ] = size(expec);

  %% Plots, and best cut point
  best_bic  = -inf;
  best_c    =   -1;
  best_idx  =   -1;

  %% Find it
  for c = 1 : k - 1
    %% Map expectation (1 .. c -> 1 .. c, (c + 1) .. k -> c + 1)
    map    = sparse([ 1 : c, (c + 1) * ones(1, k - c) ], 1 : k, ...
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
  %% Size
  [ k, n_data ] = size(expec);

  %% Find the variances
  vars = variances(model);

  %% Plots, and best cut point
  best_diff = -inf;
  best_c    =   -1;
  best_idx  =   -1;

  %% Find it
  for c = 1 : k - 1
    %% Left and right variances
    lvar = mean(vars(1 : c));
    rvar = mean(vars(c + 1 : k));
    diff = abs(lvar - rvar);

    %% Difference
    if diff > best_diff
      %% Expec
      expec_tru = sum(expec(1 : c, :), 1);
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

%% * + Min Left Heterogenenousness
function [ th ] = gaussN_mlh(l_hetero, expec, sort_scores);
  %% Find the point
  [ min_l_hetero, min_idx ] = min(l_hetero);

  %% Expec
  expec_tru = sum(expec(1 : min_idx, :), 1);
  cut_idx   = last_downfall(expec_tru, 0.5);

  %% Cut
  if isempty(cut_idx);
    th = sort_scores(length(sort_scores));
  else
    th = sort_scores(cut_idx);
  endif
endfunction

%% * + Max Right Heterogenenousness
function [ th ] = gaussN_mrh(r_hetero, expec, sort_scores);
  %% Find the point
  [ max_r_hetero, max_idx ] = max(r_hetero);

  %% Expec
  if max_idx == 1
    cut_idx   = [];
  else
    expec_tru = sum(expec(1 : max_idx - 1, :), 1);
    cut_idx   = last_downfall(expec_tru, 0.5);
  endif

  %% Cut
  if isempty(cut_idx)
    th = sort_scores(length(sort_scores));
  else
    th = sort_scores(cut_idx);
  endif
endfunction

%% * + Max Heterogenenousness Difference
function [ th ] = gaussN_mhd(l_hetero, r_hetero, expec, sort_scores);
  %% Clusters
  k = length(l_hetero);

  %% Differences
  hetero_diff = r_hetero(2 : k) - l_hetero(1 : k - 1);

  %% Find the point
  [ max_hetero_diff, max_idx ] = max(hetero_diff);

  %% Expec
  expec_tru = sum(expec(1 : max_idx, :), 1);
  cut_idx   = last_downfall(expec_tru, 0.5);

  %% Cut
  if isempty(cut_idx)
    th = sort_scores(length(sort_scores));
  else
    th = sort_scores(cut_idx);
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
	   "ll", ...
	       LogisticLoss(), ...
	   "mah",   @(data, extra) ...
	       MahalanobisDistance(data), ...
	   "quad", ...
	       KernelDistance(PolynomialKernel(2)), ...
	   "rbf",   @(data, extra) ...
	       KernelDistance(RBFKernel(str2double(extra{1}))), ...
	   "rbf_g", @(data, extra) ...
	       KernelDistanceGenerator(RBFKernelGenerator(...
                   str2double(extra{1}),str2double(extra{2}))), ...
	   "skl",   @(data, extra) ...
	       SmoothKLDivergence(str2double(extra{1}), ...
				  str2double(extra{2})), ...
	   "sqe", ...
	       SqEuclideanDistance());


%%%%%%%%%%%%%%%%
%% Thresholds %%
%%%%%%%%%%%%%%%%

%% Functions

%%%% All
function [ th ] = th_all_f(sort_scores, sort_data, sort_struth, ...
			   msort_scores, msort_model, f1_c, model)
  %% All
  th = sort_scores(length(sort_scores));
endfunction

%%%% Optimal
function [ th ] = th_best_f(sort_scores, sort_data, sort_struth, ...
			    msort_scores, msort_model, f1_c, model)
  %% Best
  [ best_f1, best_idx ] = max(f1_c);
  th = sort_scores(best_idx);
endfunction

%%%% From model
function [ th ] = th_model_f(sort_scores, sort_data, sort_struth, ...
			     msort_scores, msort_model, f1_c, model)
  th = threshold(model);
endfunction

%%% From size
function [ th ] = th_size_f(sort_scores, sort_data, sort_struth, ...
			    msort_scores, msort_model, f1_c, model)
  th = sort_scores(round(length(sort_scores) * size_ratio(sort_struth)));
endfunction

%%%% From distance
function [ th ] = th_dist_f(sort_scores, sort_data, sort_struth, ...
			    msort_scores, msort_model, f1_c, model)
  th = apply(DistanceKnee(), sort_scores);
endfunction

%%%% From 2 Gaussians
function [ th ] = th_gauss2_f(sort_scores, sort_data, sort_struth, ...
			      msort_scores, msort_model, f1_c, model)
  th = apply(GaussianKnee(), sort_scores);
endfunction

%%%% From 2 Gaussians + Noise
function [ th ] = th_gauss2n_f(sort_scores, sort_data, sort_struth, ...
			       msort_scores, msort_model, f1_c, model)
  th = apply(GaussianNoiseKnee(), sort_scores);
endfunction

%%%% From 2 Gaussians (Mapped)
function [ th ] = th_gauss2m_f(sort_scores, sort_data, sort_struth, ...
			       msort_scores, msort_model, f1_c, model)
  th = inverse(msort_model, apply(GaussianKnee(), msort_scores));
endfunction

%%%% From 2 Gaussians + Noise (Mapped)
function [ th ] = th_gauss2nm_f(sort_scores, sort_data, sort_struth, ...
				msort_scores, msort_model, f1_c, model)
  th = inverse(msort_model, apply(GaussianNoiseKnee(), msort_scores));
endfunction

%%%% From N Gaussians (Mapped)
function [ th ] = th_gaussNm_f(sort_scores, sort_data, sort_struth, ...
			       msort_scores, msort_model, f1_c, model)
  %% Model
  [ expec, model ] = gaussNm(msort_scores);

  %% Best
  th = gaussN_best(expec, model, sort_scores, f1_c);
endfunction

%%%% From N Gaussians (Mapped) -> Select smaller distance
function [ th ] = th_gaussNm_dist_f(sort_scores, sort_data, sort_struth, ...
				    msort_scores, msort_model, f1_c, model)
  %% Model
  [ expec, model ] = gaussNm(msort_scores);

  %% Dist
  th = gaussN_dist(expec, model, sort_scores, msort_scores);
endfunction

%%%% From N Gaussians (Mapped) -> 2-BIC
function [ th ] = th_gaussNm_bic2_f(sort_scores, sort_data, sort_struth, ...
				    msort_scores, msort_model, f1_c, model)
  %% Model
  [ expec, model ] = gaussNm(msort_scores);

  %% 2-BIC
  th = gaussN_bic2(expec, model, sort_scores, msort_scores);
endfunction

%%%% From N Gaussians (Mapped) -> 2-BIC (Recalculate)
function [ th ] = th_gaussNm_bic2r_f(sort_scores, sort_data, sort_struth, ...
				     msort_scores, msort_model, f1_c, model)
  %% Model
  [ expec, model ] = gaussNm(msort_scores);

  %% 2-BIC (recalculate)
  th = gaussN_bic2r(expec, model, sort_scores, msort_scores);
endfunction

%%%% From N Gaussians (Mapped) -> n-BIC
function [ th ] = th_gaussNm_bicN_f(sort_scores, sort_data, sort_struth, ...
				    msort_scores, msort_model, f1_c, model)
  %% Model
  [ expec, model ] = gaussNm(msort_scores);

  %% n-BIC
  th = gaussN_bicN(expec, model, sort_scores, msort_scores);
endfunction

%%%% From N Gaussians (Mapped) -> Var
function [ th ] = th_gaussNm_var_f(sort_scores, sort_data, sort_struth, ...
				   msort_scores, msort_model, f1_c, model)
  %% Model
  [ expec, model ] = gaussNm(msort_scores);

  %% Var
  th = gaussN_var(expec, model, sort_scores, msort_scores);
endfunction

%%%% From N Gaussians (Mapped) -> Min Left Heterogenenousness
function [ th ] = th_gaussNm_mlh_f(sort_scores, sort_data, sort_struth, ...
				   msort_scores, msort_model, f1_c, model)
  %% Model
  [ expec, model ] = gaussNm(msort_scores);

  %% Hetero
  [ c_hetero, l_hetero, r_hetero ] = gaussNm_hetero(sort_data, expec);

  %% Min Left Heterogenenousness
  th = gaussN_mlh(l_hetero, expec, sort_scores);
endfunction

%%%% From N Gaussians (Mapped) -> Max Right Heterogenenousness
function [ th ] = th_gaussNm_mrh_f(sort_scores, sort_data, sort_struth, ...
				   msort_scores, msort_model, f1_c, model)
  %% Model
  [ expec, model ] = gaussNm(msort_scores);

  %% Hetero
  [ c_hetero, l_hetero, r_hetero ] = gaussNm_hetero(sort_data, expec);

  %% Max Right Heterogenenousness
  th = gaussN_mrh(r_hetero, expec, sort_scores);
endfunction

%%%% From N Gaussians (Mapped) -> Max Heterogenenousness Difference
function [ th ] = th_gaussNm_mhd_f(sort_scores, sort_data, sort_struth, ...
				   msort_scores, msort_model, f1_c, model)
  %% Model
  [ expec, model ] = gaussNm(msort_scores);

  %% Hetero
  [ c_hetero, l_hetero, r_hetero ] = gaussNm_hetero(sort_data, expec);

  %% Max Heterogenenousness Difference
  th = gaussN_mhd(l_hetero, r_hetero, expec, sort_scores);
endfunction

%%%% From N Gaussians + Noise (Mapped)
function [ th ] = th_gaussNnm_f(sort_scores, sort_data, sort_struth, ...
				msort_scores, msort_model, f1_c, model)
  %% Model
  [ expec, model ] = gaussSm(msort_scores);

  %% Best
  [ th ] = gaussN_best(expec, model, sort_scores, f1_c);
endfunction

%%%% From N Gaussians + Noise (Mapped) -> Select smaller distance
function [ th ] = th_gaussNnm_dist_f(sort_scores, sort_data, sort_struth, ...
				     msort_scores, msort_model, f1_c, model)
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
th_gaussNm_bic2r = struct("name", "GM-N-BR", "find", @th_gaussNm_bic2r_f, ...
			  "level", 2);
th_gaussNm_bicN  = struct("name", "GM-N-BN", "find", @th_gaussNm_bicN_f,  ...
			  "level", 2);
th_gaussNm_var   = struct("name", "GM-N-V",  "find", @th_gaussNm_var_f,   ...
			  "level", 2);
th_gaussNm_mlh   = struct("name", "GM-N-LH", "find", @th_gaussNm_mlh_f,   ...
			  "level", 2);
th_gaussNm_mrh   = struct("name", "GM-N-RH", "find", @th_gaussNm_mrh_f,   ...
			  "level", 2);
th_gaussNm_mhd   = struct("name", "GM-N-HD", "find", @th_gaussNm_mhd_f,   ...
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
	       th_gaussNm_bic2, th_gaussNm_bic2r, th_gaussNm_bicN, ...
	       th_gaussNm_var, th_gaussNm_mlh, th_gaussNm_mrh, ...
	       th_gaussNm_mhd, th_gaussNnm, th_gaussNnm_dist ];


%%%%%%%%%%%%%
%% Methods %%
%%%%%%%%%%%%%

%% Objects
method_bbocc = ...
    struct("args", 0, ...
	   "help", "", ...
	   "make", @(dist, data, struth, extra) ...
	       BBOCC(dist, struct("size_ratio", size_ratio(struth))), ...
	   "scor", true(), ...
	   "ths",  ths_simple);
method_bbocc_s = ...
    struct("args", 0, ...
	   "help", "", ...
	   "make", @(dist, data, struth, extra) ...
	       BBOCC(dist, struct("size_ratio", size_ratio(struth), ...
				  "centroid_finder", ...
				         SmoothCentroids(1, 2))), ...
	   "scor", true(), ...
	   "ths",  ths_simple);
method_bbcpress = ...
    struct("args", 0, ...
	   "help", "", ...
	   "make", @(dist, data, struth, extra) ...
	       BBCPress(dist, struct("size_ratio", size_ratio(struth))), ...
	   "scor", true(), ...
	   "ths",  ths_simple);
method_bbcpress_s = ...
    struct("args", 0, ...
	   "help", "", ...
	   "make", @(dist, data, struth, extra) ...
	       BBCPress(dist, struct("size_ratio", size_ratio(struth), ...
				     "centroid_finder", ...
				         SmoothCentroids(1, 2))), ...
	   "scor", true(), ...
	   "ths",  ths_simple);
method_ewocs_bern = ...
    struct("args", 2, ...
	   "help", "<ensemble_size>, <max_clusters>", ...
	   "make", @(dist, data, struth, extra) ...
	       EWOCS(Bernoulli(), ...
		     struct("ensemble_size", str2double(extra{1}), ...
			    "max_clusters", str2double(extra{2}), ...
			    "interpolator", "null")), ...
	   "scor", true(), ...
	   "ths",  ths_ewocs);
method_ewocs_hproj = ...
    struct("args", 2, ...
	   "help", "<ensemble_size>, <max_clusters>", ...
	   "make", @(dist, data, struth, extra) ...
	   EWOCS(RandomProj(struct("soft_alpha", nan,
				   "homogeneous", true())), ...
		 struct("ensemble_size", str2double(extra{1}), ...
			"max_clusters", str2double(extra{2}), ...
			"interpolator", "null")), ...
	   "scor", true(), ...
	   "ths",  ths_ewocs);
method_ewocs_hvoro = ...
    struct("args", 2, ...
	   "help", "<ensemble_size>, <max_clusters>", ...
	   "make", @(dist, data, struth, extra) ...
           EWOCS(Voronoi(dist, struct("soft_alpha", nan)), ...
                 struct("ensemble_size", str2double(extra{1}), ...
                        "max_clusters", str2double(extra{2}), ...
                        "interpolator", "null")), ...
	   "scor", true(), ...
	   "ths",  ths_ewocs);
method_ewocs_kmeans = ...
    struct("args", 2, ...
	   "help", "<ensemble_size>, <max_clusters>", ...
	   "make", @(dist, data, struth, extra) ...
	   EWOCS(KMeans(dist, struct("change_threshold", 0.1)), ...
		 struct("ensemble_size", str2double(extra{1}), ...
			"max_clusters", str2double(extra{2}), ...
			"interpolator", "null")), ...
	   "scor", true(), ...
	   "ths",  ths_ewocs);
method_ewocs_rproj = ...
    struct("args", 2, ...
	   "help", "<ensemble_size>, <max_clusters>", ...
	   "make", @(dist, data, struth, extra) ...
	   EWOCS(RandomProj(struct("soft_alpha", nan)), ...
		 struct("ensemble_size", str2double(extra{1}), ...
			"max_clusters", str2double(extra{2}), ...
			"interpolator", "null")), ...
	   "scor", true(), ...
	   "ths",  ths_ewocs);
method_ewocs_voro = ...
    struct("args", 3, ...
	   "help", "<soft_alpha>, <ensemble_size>, <max_clusters>", ...
	   "make", @(dist, data, struth, extra) ...
           EWOCS(Voronoi(dist, struct("soft_alpha", str2double(extra{1}))), ...
                 struct("ensemble_size", str2double(extra{2}), ...
                        "max_clusters", str2double(extra{3}), ...
                        "interpolator", "null")), ...
	   "scor", true(), ...
	   "ths",  ths_ewocs);
method_kmd_b = ...
    struct("args", 3, ...
	   "help", "<start_size>, <min_size>, <max_iterations>", ...
	   "make", @(dist, data, struth, extra) ...
	   KMD(@KMDBernoulli, [], ...
	       struct("start_size",     str2double(extra{1}), ...
		      "min_size",       str2double(extra{2}), ...
		      "max_iterations", str2double(extra{3}))), ...
	   "scor", false(), ...
	   "ths",  []);
method_kmd_gu = ...
    struct("args", 3, ...
	   "help", "<start_size>, <min_size>, <max_iterations>", ...
	   "make", @(dist, data, struth, extra) ...
	   KMD(@KMDGaussian, @KMDUniform, ...
	       struct("start_size",     str2double(extra{1}), ...
		      "min_size",       str2double(extra{2}), ...
		      "max_iterations", str2double(extra{3}))), ...
	   "scor", false(), ...
	   "ths",  []);
method_kmd_m = ...
    struct("args", 3, ...
	   "help", "<start_size>, <min_size>, <max_iterations>", ...
	   "make", @(dist, data, struth, extra) ...
	   KMD(@KMDMultinomial, [], ...
	       struct("start_size",     str2double(extra{1}), ...
		      "min_size",       str2double(extra{2}), ...
		      "max_iterations", str2double(extra{3}))), ...
	   "scor", false(), ...
	   "ths",  []);
method_soft_bbc = ...
    struct("args", 1, ...
	   "help", "<beta>", ...
	   "make", @(dist, data, struth, extra) ...
	   SeqEM({ KMeans(dist),
		   SoftBBCEM(dist, ...
			     struct("beta", str2double(extra{1}))) }), ...
	   "scor", true(), ...
	   "ths",  ths_simple);

%% Index
methods = ...
    struct("bbocc",        method_bbocc, ...
	   "bbocc_s",      method_bbocc_s, ...
	   "bbcpress",     method_bbcpress, ...
	   "bbcpress_s",   method_bbcpress_s, ...
	   "ewocs_bern",   method_ewocs_bern, ...
	   "ewocs_hproj",  method_ewocs_hproj, ...
	   "ewocs_hvoro",  method_ewocs_hvoro, ...
	   "ewocs_kmeans", method_ewocs_kmeans, ...
	   "ewocs_rproj",  method_ewocs_rproj, ...
	   "ewocs_voro",   method_ewocs_voro, ...
	   "kmd_b",        method_kmd_b, ...
	   "kmd_gu",       method_kmd_gu, ...
	   "kmd_m",        method_kmd_m, ...
	   "soft_bbc",     method_soft_bbc);
