%% -*- mode: octave; -*-

%% Random clustering
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = Random(opts = struct())

  %% Check arguments
  if ~any(nargin() == [ 0, 1 ])
    usage("[ this ] = Random([opts])");
  endif

  %% This object
  this = struct();

  %% Softening alpha
  %% Default -> 0.1
  this.soft_alpha = getfielddef(opts, "soft_alpha", 0.1);

  %% Verbose
  %% Default -> false
  this.verbose = getfielddef(opts, "verbose", false());

  %% Bless
  %% And add inheritance
  this = class(this, "Random", ...
	       Simple());
endfunction
