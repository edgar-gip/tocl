%% -*- mode: octave; -*-

%% Ensemble Weak One-Class Scoring
%% Linear Kernel

%% Author: Edgar Gonzalez

function [ result ] = apply(this, source, target)

  %% The linear kernel is the dot product

  %% One or two arguments?
  if nargin() < 3
    result = sum(source .* source);
  else
    result = source' * target;
  endif
endfunction
