%% -*- mode: octave; -*-

%% Kernel-Based Distance Generator
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = KernelDistanceGenerator(kernel_gen)

  %% Check arguments
  if nargin() ~= 1
    usage("[ this ] = KernelDistanceGenerator(kernel_gen)");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.kernel_gen = kernel_gen;

  %% Bless
  %% And add inheritance
  this = class(this, "KernelDistanceGenerator", ...
               Simple());
endfunction
