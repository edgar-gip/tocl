%% -*- mode: octave; -*-

%% Squared Euclidean Distance
%% Distance

%% Author: Edgar Gonzalez

function [ dists ] = apply(this, source, target)

  %% Check arguments
  if ~any(nargin() == [ 2, 3 ])
    usage("[ dists ] = @SqEuclideanDistance/apply(this, source [, target])");
  endif

  %% Call helper functions
  if nargin() == 2
    dists = sq_euclidean_distance1(source);
  else %% nargin() == 3
    dists = sq_euclidean_distance2(source, target);
  endif
endfunction
