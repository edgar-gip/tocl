%% -*- mode: octave; -*-

%% Hypersphere One-Class Clustering
%% Clustering function

%% Author: Edgar Gonzalez

function [ expec, model, info ] = cluster(this, data, k, expec_0)

  %% Check arguments
  if ~any(nargin() == [ 2, 3, 4 ])
    usage(cstrcat("[ expec, model, info ] = ",
		  "@HOCC/cluster(this, data [, k [, expec_0]])"));
  endif

  %% The number of clusters must be 1
  if nargin() >= 3 && k ~= 1
    usage("k must be 1 if given");
  endif

  %% Warn that expec_0 is ignored
  if nargin() == 4 && ~isempty(expec_0)
    warning("expec_0 is ignored");
  endif

  %% Size
  [ n_feats, n_samples ] = size(data);
  target_size = max([2, round(n_samples * this.size_ratio)]);

  %% Find the divergence matrix
  divs = apply(this.divergence, data);

  %% Sort the matrix
  [ sort_divs, sort_indices ] = sort(divs);

  %% Find the minimum column
  [ radius, best_idx ] = min(sort_divs(target_size, :));

  %% Cluster
  cluster = find(sort_divs(:, best_idx) <= radius);
  size    = length(cluster);

  %% Model
  model = BregmanBallModel(this.divergence, data(:, best_idx), radius);

  %% Expectation
  expec = sparse(ones(1, size), cluster, ones(1, size), ...
		 1, n_samples);

  %% Info
  info              = struct();
  info.centroid_idx = best_idx;
endfunction
