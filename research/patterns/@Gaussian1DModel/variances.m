%% -*- mode: octave; -*-

%% 1-D Gaussian distribution clustering
%% Variances

%% Author: Edgar Gonzalez

function [ v ] = variances(this);

  %% Check arguments
  if nargin() ~= 1
    usage("[ v ] = @Gaussian1DModel/variances(this)");
  endif

  %% Return them
  v = this.var;
endfunction
