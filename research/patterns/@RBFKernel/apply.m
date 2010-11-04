%% -*- mode: octave; -*-

%% RBF Kernel
%% Kernel function

%% Author: Edgar Gonzalez

function [ result ] = apply(this, source, target)

  %% Check arguments
  if ~any(nargin() == [ 2, 3 ])
    usage("[ result ] = @RBFKernel/apply(this, source [, target])");
  endif

  %% Sizes
  [ n_feats, n_source ] = size(source);

  %% Squared euclidean distance
  %% | x - y |^2 = x \cdot x + y \cdot y - 2 \cdot x \cdot y
  %% @see @SqEuclideanDistance/apply
  if nargin() < 3
    dot         = source' * source;
    self_source = diag(dot, 0)';
    result      = self_source' * ones(1, n_source) + ...
                  ones(n_source, 1) * self_source - 2 * dot;

  else
    [ n_feats, n_target ] = size(target);

    self_source = sum(source .* source);
    self_target = sum(target .* target);
    dot         = source' * target;
    result      = self_source' * ones(1, n_target) + ...
                  ones(n_source, 1) * self_target - 2 * dot;
  endif

  %% Now, apply RBF
  result *= -this.rbf_gamma;
  result  = exp(result);
endfunction
