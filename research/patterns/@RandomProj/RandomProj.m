%% -*- mode: octave; -*-

%% Random projection clustering
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = RandomProj(opts = struct())

  %% Check arguments
  if ~any(nargin() == [ 0, 1 ])
    usage("[ this ] = RandomProj([opts])");
  endif

  %% This object
  this = struct();

  %% Softening alpha
  %% Default -> 0.1
  this.soft_alpha = getfielddef(opts, "soft_alpha", 0.1);

  %% Homogeneous
  %% Default -> false
  this.homogeneous = getfielddef(opts, "homogeneous", false());

  %% Verbose
  %% Default -> false
  this.verbose = getfielddef(opts, "verbose", false());

  %% Bless
  %% And add inheritance
  this = class(this, "RandomProj", ...
               Simple());
endfunction
