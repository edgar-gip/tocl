%% -*- mode: octave; -*-

%% Linear Kernel
%% Kernel function

%% Author: Edgar Gonzalez

function [ result ] = apply(this, source, target)

  %% Check arguments
  if ~any(nargin() == [ 2, 3 ])
    usage("[ result ] = @LinearKernel/apply(this, source [, target])");
  endif

  %% The linear kernel is the dot product
  if nargin() == 2
    result = source' * source;
  else %% nargin() == 3
    result = source' * target;
  endif
endfunction
