%% -*- mode: octave; -*-

%% Squared Euclidean Distance

%% Author: Edgar Gonzalez

function [ dists ] = sq_euclidean_distance2(source, target)

  %% Sizes
  [ n_dims, n_source ] = size(source);
  [ n_dims, n_target ] = size(target);

  %% | x - y |^2 = x \cdot x + y \cdot y - 2 \cdot x \cdot y
  self_source = sum(source .* source);
  self_target = sum(target .* target);
  dot         = source' * target;
  dists       = self_source' * ones(1, n_target) + ...
                ones(n_source, 1) * self_target - 2 * dot;
endfunction
