%% -*- mode: octave; -*-

%% 1D Gaussian distribution clustering
%% Random expectation

%% Author: Edgar Gonzalez

function [ expec ] = random_expec(this, data, k)
  %% Sizes
  [ n_dims, n_data ] = size(data);

  %% Sort the data
  [ sort_data, sort_indices ] = sort(data);

  %% Clusters
  clusters = zeros(1, n_data);

  %% Cluster size
  cl_size  = floor(n_data / k);
  cl_extra = mod  (n_data,  k);

  %% For each one
  base = 1;
  for cl = 1 : k
    this_size = cl_size + (cl <= cl_extra);
    clusters(sort_indices(base : base + this_size - 1)) = cl;
    base += this_size;
  endfor

  %% Sparse
  expec   = sparse(clusters, 1 : n_data, ones(1, n_data), k, n_data);
endfunction
