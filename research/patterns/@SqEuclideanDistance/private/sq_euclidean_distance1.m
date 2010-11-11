%% -*- mode: octave; -*-

%% Squared Euclidean Distance

%% Author: Edgar Gonzalez

function [ dists ] = sq_euclidean_distance1(source)

  %% Sizes
  [ n_dims, n_source ] = size(source);

  %% | x - y |^2 = x \cdot x + y \cdot y - 2 \cdot x \cdot y
  dot         = source' * source;
  self_source = diag(dot, 0)';
  dists       = self_source' * ones(1, n_source) + ...
                ones(n_source, 1) * self_source - 2 * dot;
endfunction
