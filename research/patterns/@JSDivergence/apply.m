%% -*- mode: octave; -*-

%% Jensen-Shannon Divergence
%% Distance

%% Author: Edgar Gonzalez

function [ dists ] = apply(this, source, target)

  %% Check arguments
  if ~any(nargin() == [ 2, 3 ])
    usage("[ dists ] = @JSDivergence/apply(this, source [, target])");
  endif

  %% Call helper functions
  if nargin() == 2
    dists = js_divergence1(source);
  else %% nargin() == 3
    dists = js_divergence2(source, target);
  endif
endfunction
