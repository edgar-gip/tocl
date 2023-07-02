%% -*- mode: octave; -*-

%% Voronoi clustering
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = Voronoi(distance, opts = struct())

  %% Check arguments
  if ~any(nargin() == [ 1, 2 ])
    usage("[ this ] = Voronoi(distance [, opts])");
  endif

  %% This object
  this = struct();

  %% Distance
  this.distance = distance;

  %% Softening alpha
  %% Default -> 0.1
  this.soft_alpha = getfielddef(opts, "soft_alpha", 0.1);

  %% Verbose
  %% Default -> false
  this.verbose = getfielddef(opts, "verbose", false());

  %% Bless
  %% And add inheritance
  this = class(this, "Voronoi", ...
               Simple());
endfunction
