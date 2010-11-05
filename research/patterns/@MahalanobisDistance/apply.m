%% -*- mode: octave; -*-

%% Mahalanobis Distance
%% Distance

%% Author: Edgar Gonzalez

function [ dists ] = apply(this, source, target)

  %% Check arguments
  if ~any(nargin() == [ 2, 3 ])
    usage("[ dists ] = @MahalanobisDistance/apply(this, source [, target])");
  endif

  %% Call helper functions
  if nargin() == 2
    dists = mahalanobis_distance1(this.data_invc, source);
  else %% nargin() == 3
    dists = mahalanobis_distance2(this.data_invc, source, target);
  endif
endfunction
