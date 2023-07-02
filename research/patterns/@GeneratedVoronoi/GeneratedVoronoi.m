%% -*- mode: octave; -*-

%% Voronoi clustering (generated)
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = GeneratedVoronoi(distance_gen, opts = struct())

  %% Check arguments
  if ~any(nargin() == [ 1, 2 ])
    usage("[ this ] = GeneratedVoronoi(distance_gen [, opts])");
  endif

  %% This object
  this = struct();

  %% Distance generator
  this.distance_gen = distance_gen;

  %% Softening alpha
  %% Default -> 0.1
  this.soft_alpha = getfielddef(opts, "soft_alpha", 0.1);

  %% Verbose
  %% Default -> false
  this.verbose = getfielddef(opts, "verbose", false());

  %% Bless
  %% And add inheritance
  this = class(this, "GeneratedVoronoi", ...
               Simple());
endfunction
