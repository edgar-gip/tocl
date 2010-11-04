%% -*- mode: octave; -*-

%% Polynomial Kernel
%% Self-Kernel function

%% Author: Edgar Gonzalez

function [ result ] = apply(this, source)

  %% Check arguments
  if nargin() ~= 2
    usage("[ result ] = @PolynomialKernel/self_apply(this, source)");
  endif

  %% Find dot product
  result = sum(source .* source);

  %% Now, add homogeneousness and elevate
  result += this.homogeneous;
  result .^ this.degree;
endfunction
