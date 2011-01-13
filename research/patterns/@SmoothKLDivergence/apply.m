%% -*- mode: octave; -*-

%% Smoothed Kullback-Leibler Divergence
%% Distance

%% Author: Edgar Gonzalez

function [ dists ] = apply(this, source, target)

  %% Check arguments
  if ~any(nargin() == [ 2, 3 ])
    usage("[ dists ] = @SmoothKLDivergence/apply(this, source [, target])");
  endif

  %% Call helper functions
  if nargin() == 2
    dists = skl_divergence1(this.term, source);
  else %% nargin() == 3
    dists = skl_divergence2(this.term, source, target);
  endif
endfunction
