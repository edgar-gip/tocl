%% -*- mode: octave; -*-

%% Voronoi clustering
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = Voronoi(distance, opts)

  %% kernel must be given
  if nargin() < 1 || nargin() > 2
    usage("[ this ] = Voronoi(distance [, opts])");
  endif

  %% Options given?
  if nargin() < 2
    opts = struct();
  endif

  %% This object
  this = struct();

  %% Distance
  this.distance = distance;

  %% Softening alpha
  %% Default -> 0.1
  this.soft_alpha = getfielddef(opts, "soft_alpha", 0.1);

  %% Variance threshold
  %% Default -> 1e-6
  this.em_threshold = getfielddef(opts, "em_threshold", 1e-6);

  %% Verbose
  %% Default -> false
  this.verbose = getfielddef(opts, "verbose", false());

  %% Bless
  %% And add inheritance
  this = class(this, "Voronoi", ...
	       Simple());
endfunction
