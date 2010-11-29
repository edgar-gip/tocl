%% -*- mode: octave; -*-

%% Kernel-Based Distance Generator
%% Generate

%% Author: Edgar Gonzalez

function [ distance ] = generate(this)

  %% Check arguments
  if nargin() ~= 1
     usage("[ distance ] = @KernelDistanceGenerator/generate(this)");
  endif

  %% Generate a kernel, and put it inside a distance
  kernel   = generate(this.kernel_gen);
  distance = KernelDistance(kernel);
endfunction
