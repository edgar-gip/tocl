%% -*- mode: octave; -*-

%% 1-D Gaussian distribution clustering
%% Means

%% Author: Edgar Gonzalez

function [ m ] = means(this);

  %% Check arguments
  if nargin() ~= 1
    usage("[ m ] = @Gaussian1DModel/means(this)");
  endif

  %% Return them
  m = this.mean;
endfunction
