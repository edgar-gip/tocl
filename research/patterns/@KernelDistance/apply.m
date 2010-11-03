%% -*- mode: octave; -*-

%% Kernel Distance
%% Distance

%% Author: Edgar Gonzalez

function [ dists ] = apply(this, source, target)
  %% Sizes
  [ n_feats, n_source ] = size(source);
  [ n_feats, n_target ] = size(target);

  %% | x - y |^2 = x \cdot x + y \cdot y - 2 \cdot x \cdot y
  self_source = apply(this.kernel, source);
  self_target = apply(this.kernel, target);
  dot         = apply(this.kernel, source, target);
  dists       = self_source' * ones(1, n_target) + ...
                ones(n_source, 1) * self_target - 2 * dot;
endfunction
