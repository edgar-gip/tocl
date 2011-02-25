%% -*- mode: octave; -*-

%% Sammon mapping
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = Sammon(opts = struct())

  %% Check arguments
  if ~any(nargin() == [ 0, 1 ])
    usage("[ this ] = Sammon([ opts ])");
  endif

  %% This object
  this = struct();

  %% Maximum number of iterations
  %% Default -> 100
  this.em_iterations = getfielddef(opts, "max_iterations", 100);

  %% Change threshold
  %% Default -> 1e-6
  this.em_threshold = getfielddef(opts, "change_threshold", 1e-6);

  %% Magic factor
  %% Default -> 0.35
  this.min_size = getfielddef(opts, "magic_factor", 0.35);

  %% Bless
  %% And add inheritance
  this = class(struct(), "Sammon", ...
	       Simple());
endfunction
