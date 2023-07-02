%% -*- mode: octave; -*-

%% Density Gradient Enumeration (DGRADE) with automatical s_one tuning.
%% Clustering function

%% Author: Edgar Gonzalez

function [ expec, model, info ] = cluster(this, data, k, expec_0)

  %% Check arguments
  if ~any(nargin() == [ 2, 3, 4 ])
    usage(cstrcat("[ expec, model, info ] = ",
                  "@AutoDGRADE/cluster(this, data [, k [, expec_0]])"));
  endif

  %% Warn that k is ignored
  if nargin() >= 3 && ~isempty(k)
    usage("k is ignored");
  endif

  %% Warn that expec_0 is ignored
  if nargin() == 4 && ~isempty(expec_0)
    warning("expec_0 is ignored");
  endif

  %% Size
  [ n_dims, n_samples ] = size(data);
  target_size = round(n_samples * this.size_ratio);

  %% Divergence matrix
  divs = apply(this.divergence, data);
  [ sorted_divs, nearest_neighbours ] = sort(divs, 2);

  %% Best stability so far
  best_k = 0;
  best_stability = 0;
  best_s_one = 0;

  %% Current stability
  cur_k = 0;
  cur_stability = 0;
  cur_min_s_one = 0;

  %% Find the most stable s_one
  k = inf();
  s_one = 1;
  prune = false();
  while k > 1 && s_one < n_samples && ~prune
    %% Cluster
    [ hard_expec, centroid_indices, radius ] = ...
        cluster_sone(this, n_samples, target_size, s_one, ...
                     divs, sorted_divs, nearest_neighbours);

    %% Check number of clusters
    k = length(centroid_indices);
    if this.verbose
      fprintf(2, "s_one=%d gives k=%d clusters\n", s_one, k);
    endif

    %% Series continues?
    if k == cur_k
      ++cur_stability;

      %% Prune
      if cur_k == 2 && cur_stability > best_stability
        best_k = 2;
        best_stability = cur_stability;
        best_s_one = cur_min_s_one;
        prune = true();
      endif

    else
      %% Update best
      if cur_stability > best_stability
        best_k = cur_k;
        best_stability = cur_stability;
        best_s_one = cur_min_s_one;
      endif

      %% New k value
      cur_k = k;
      cur_stability = 1;
      cur_min_s_one = s_one;
    endif

    %% Next
    ++s_one;
  endwhile

  %% Log
  if this.verbose
    if prune
      fprintf(2, "Most stable k=%d (s_one=%d-%d+ [pruned])\n", ...
              best_k, best_s_one, best_s_one + best_stability - 1);
    else
      fprintf(2, "Most stable k=%d (s_one=%d-%d)\n", ...
              best_k, best_s_one, best_s_one + best_stability - 1);
    endif
  endif

  %% Call helper to cluster with most stable s_one
  [ hard_expec, centroid_indices, radius ] = ...
      cluster_sone(this, n_samples, target_size, best_s_one, ...
                   divs, sorted_divs, nearest_neighbours);

  %% Centroids
  centroids = data(:, centroid_indices);
  k = length(centroid_indices);

  %% Expectation
  expec_on = find(hard_expec);
  expec    = ...
      sparse(hard_expec(expec_on), expec_on, ones(1, length(expec_on)), ...
             k, n_samples);

  %% Model
  model = BregmanBallModel(this.divergence, centroids, radius);

  %% Info
  info = struct();
endfunction
