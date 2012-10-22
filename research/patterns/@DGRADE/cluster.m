%% -*- mode: octave; -*-

%% Density Gradient Enumeration (DGRADE)
%% Clustering function

%% Author: Edgar Gonzalez

function [ expec, model, info ] = cluster(this, data, k, expec_0)

  %% Check arguments
  if ~any(nargin() == [ 2, 3, 4 ])
    usage(cstrcat("[ expec, model, info ] = ",
		  "@DGRADE/cluster(this, data [, k [, expec_0]])"));
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

  if n_samples <= this.s_one
    %% Singleton cluster
    k = 1;

    %% Call helper
    [ hard_expec, centroids, radius ] = ...
	cluster_singleton(this, n_samples, target_size, data);
  else
    %% Divergence matrix
    divs = apply(this.divergence, data);
    [ sorted_divs, nearest_neighbours ] = sort(divs, 2);

    %% Call helper
    [ hard_expec, centroid_indices, radius ] = ...
	cluster_sone(this, n_samples, target_size, this.s_one, ...
		     divs, sorted_divs, nearest_neighbours);

    %% Centroids
    centroids = data(:, centroid_indices);
    k = length(centroid_indices);
  endif

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
