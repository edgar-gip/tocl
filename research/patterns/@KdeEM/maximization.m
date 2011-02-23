%% -*- mode: octave; -*-

%% Kernel Density Estimation EM clustering
%% Maximization

%% Author: Edgar Gonzalez

function [ model ] = maximization(this, data, expec)

  %% Check arguments
  if nargin() ~= 3
    usage("[ model ] = @KdeEM/maximization(this, data, expec)");
  endif

  %% Just store it
  model = KdeEMModel(this.kernel, data, expec);
endfunction
