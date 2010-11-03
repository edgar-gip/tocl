%% -*- mode: octave; -*-

%% Ensemble Weak One-Class Scoring
%% Polynomial Kernel

%% Author: Edgar Gonzalez

function [ result ] = apply(this, source, target)
  %% Sizes
  [ n_feats, n_source ] = size(source);

  %% Squared euclidean distance
  %% | x - y |^2 = x \cdot x + y \cdot y - 2 \cdot x \cdot y
  %% @see @SqEuclideanDistance/distance

  %% One or two arguments?
  if nargin() < 3
    %% The kernel is always 1
    result = ones(1, n_source);
  else
    %% Size
    [ n_feats, n_target ] = size(target);

    %% Distances
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
