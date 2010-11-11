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
  [ n_dims, n_source ] = size(source);

  %% Squared euclidean distance
  %% Call helper functions
  if nargin() == 2
    result = sq_euclidean_distance1(source);
  else %% nargin() == 3
    result = sq_euclidean_distance2(source, target);
  endif

  %% Now, apply RBF
  result *= -this.rbf_gamma;
  result  = exp(result);
endfunction
