%% -*- mode: octave; -*-

%% k-Means clustering
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = KMeans(divergence, opts = struct())

  %% Check arguments
  if ~any(nargin() == [ 1, 2 ])
    usage("[ this ] = KMeans(divergence [, opts])");
  endif

  %% This object
  this = struct();

  %% Divergence
  this.divergence = divergence;

  %% Maximum number of iterations
  %% Default -> 100
  this.max_iterations = getfielddef(opts, "max_iterations", 100);

  %% Change threshold
  %% Default -> 1
  this.change_threshold = getfielddef(opts, "change_threshold", 1);

  %% Verbose
  %% Default -> false
  this.verbose = getfielddef(opts, "verbose", false());

  %% Bless
  %% And add inheritance
  this = class(this, "KMeans", ...
	       Simple());
endfunction
