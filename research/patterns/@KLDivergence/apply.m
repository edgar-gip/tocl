%% -*- mode: octave; -*-

%% Kullback-Leibler Divergence
%% Distance

%% Author: Edgar Gonzalez

function [ dists ] = apply(this, source, target)

  %% Check arguments
  if ~any(nargin() == [ 2, 3 ])
    usage("[ dists ] = @KLDivergence/apply(this, source [, target])");
  endif

  %% Call helper functions
  if nargin() == 2
    dists = kl_divergence1(source);
  else %% nargin() == 3
    dists = kl_divergence2(source, target);
  endif
endfunction
