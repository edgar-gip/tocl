%% -*- mode: octave; -*-

%% Kernel-Based Distance
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = KernelDistance(kernel)

  %% Check arguments
  if nargin() ~= 1
    usage("[ this ] = KernelDistance(kernel)");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.kernel = kernel;

  %% Bless
  %% And add inheritance
  this = class(this, "KernelDistance", ...
	       Simple());
endfunction
