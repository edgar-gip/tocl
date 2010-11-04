%% -*- mode: octave; -*-

%% RBF Kernel
%% Self-Kernel function

%% Author: Edgar Gonzalez

function [ result ] = self_apply(this, source)

  %% Check arguments
  if ~any(nargin() == [ 2, 3 ])
    usage("[ result ] = @RBFKernel/self_apply(this, source)");
  endif

  %% Sizes
  [ n_feats, n_source ] = size(source);

  %% The kernel is always 1
  result = ones(1, n_source);
endfunction
