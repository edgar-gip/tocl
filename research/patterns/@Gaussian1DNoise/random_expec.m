%% -*- mode: octave; -*-

%% 1D Gaussian distribution clustering (with noise cluster)
%% Random expectation

%% Author: Edgar Gonzalez

function [ expec ] = random_expec(this, data, k)
  %% Sizes
  [ n_dims, n_data ] = size(data);

  %% Sort the data
  [ sort_data, sort_indices ] = sort(data);

  %% Clusters
  clusters = zeros(1, n_data);

  %% Effective clusters (discarding 1st, which is BG)
  eff_k = k - 1;

  %% Cluster size
  cl_size  = floor(n_data / eff_k);
  cl_extra = mod  (n_data,  eff_k);

  %% For each one
  base = 1;
  for cl = 1 : eff_k
    this_size = cl_size + (cl <= cl_extra);
    clusters(sort_indices(base : base + this_size - 1)) = 1 + cl;
    base += this_size;
  endfor

  %% Sparse
  expec = sparse([ ones(1, n_data), clusters ], ...
		 [ 1 : n_data, 1 : n_data], ...
		 0.5 * ones(1, 2 * n_data), k, n_data);
endfunction
