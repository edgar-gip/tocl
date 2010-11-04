%% -*- mode: octave; -*-

%% Linear Kernel
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = LinearKernel()

  %% Check arguments
  if nargin() ~= 0
    usage("[ this ] = LinearKernel()");
  endif

  %% Bless
  %% And add inheritance
  this = class(struct(), "LinearKernel", ...
	       Simple());
endfunction
