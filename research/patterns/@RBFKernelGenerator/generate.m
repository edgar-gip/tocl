%% -*- mode: octave; -*-

%% RBF Kernel Generator
%% Generate

%% Author: Edgar Gonzalez

function [ kernel ] = generate(this)

  %% Check arguments
  if nargin() ~= 1
     usage("[ distance ] = @KernelDistanceGenerator/generate(this)");
  endif

  %% Generate a value for gamma
  gamma = this.min_rbf_gamma * exp(this.log_range * rand());

  %% Generate a kernel
  kernel = RBFKernel(gamma);
endfunction
