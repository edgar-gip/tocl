%% -*- mode: octave; -*-

%% Polynomial Kernel
%% Kernel function

%% Author: Edgar Gonzalez

function [ result ] = apply(this, source, target)

  %% Check arguments
  if ~any(nargin() == [ 2, 3 ])
    usage("[ result ] = @PolynomialKernel/apply(this, source [, target])");
  endif

  %% Find dot product
  if nargin() == 2
    result = source' * source;
  else %% nargin() == 3
    result = source' * target;
  endif

  %% Now, add homogeneousness and elevate
  result += this.homogeneous;
  result .^ this.degree;
endfunction
