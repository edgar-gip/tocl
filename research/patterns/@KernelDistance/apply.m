%% -*- mode: octave; -*-

%% Kernel Distance
%% Distance

%% Author: Edgar Gonzalez

function [ dists ] = apply(this, source, target)

  %% Check arguments
  if ~any(nargin() == [ 2, 3 ])
    usage("[ dists ] = @KernelDistance/apply(this, source [, target])");
  endif

  %% Sizes
  [ n_feats, n_source ] = size(source);

  %% | x - y |^2 = x \cdot x + y \cdot y - 2 \cdot x \cdot y
  if nargin() == 2
    dot         = apply(this.kernel, source);
    self_source = diag(dot, 0)';
    dists       = self_source' * ones(1, n_source) + ...
                  ones(n_source, 1) * self_source - 2 * dot;

  else %% nargin() == 3
    [ n_feats, n_target ] = size(target);

    self_source = self_apply(this.kernel, source);
    self_target = self_apply(this.kernel, target);
    dot         = apply(this.kernel, source, target);
    dists       = self_source' * ones(1, n_target) + ...
                  ones(n_source, 1) * self_target - 2 * dot;
  endif
endfunction
