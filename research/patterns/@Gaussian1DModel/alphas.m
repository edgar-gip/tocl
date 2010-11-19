%% -*- mode: octave; -*-

%% 1-D Gaussian distribution clustering
%% A priori probabilities

%% Author: Edgar Gonzalez

function [ a ] = alphas(this);

  %% Check arguments
  if nargin() ~= 1
    usage("[ m ] = @Gaussian1DModel/alphas(this)");
  endif

  %% Return them
  a = this.alpha;
endfunction
