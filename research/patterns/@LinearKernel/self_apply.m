%% -*- mode: octave; -*-

%% Linear Kernel
%% Self-Kernel function

%% Author: Edgar Gonzalez

function [ result ] = apply(this, source)

  %% Check arguments
  if nargin() ~= 2
    usage("[ result ] = @LinearKernel/self_apply(this, source)");
  endif

  %% Find dot product
  result = sum(source .* source);
endfunction
