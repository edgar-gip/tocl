%% -*- mode: octave; -*-

%% Kernel Density Estimation EM clustering
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = KdeEM(kernel, opts = struct())

  %% Check arguments
  if ~any(nargin() == [ 1, 2 ])
    usage("[ this ] = KdeEM(kernel, [ opts ])");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.kernel = kernel;

  %% Verbose
  %% Default -> false
  this.verbose = getfielddef(opts, "verbose", false());

  %% Bless
  %% And add inheritance
  this = class(this, "KdeEM", ...
	       EM(opts));
endfunction
