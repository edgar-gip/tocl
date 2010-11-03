%% -*- mode: octave; -*-

%% Ensemble Weak One-Class Scoring
%% Polynomial Kernel

%% Author: Edgar Gonzalez

function [ result ] = apply(this, source, target)

  %% Find dot product
  %% One or two arguments?
  if nargin() < 3
    result = sum(source .* source);
  else
    result = source' * target;
  endif

  %% Now, add homogeneousness and elevate
  result += this.homogeneous;
  result .^ this.degree;
endfunction
