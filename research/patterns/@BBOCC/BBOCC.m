%% -*- mode: octave; -*-

%% Batch Ball One-Class Clustering
%% From:
%%   Gunjan Gupta, Joydeep Gosh
%%   "Robust One-Class Clustering using Hybrid Global and Local Search"
%%   International Conference on Machine Learning (ICML), 2005

%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = BBOCC(divergence, opts = struct())

  %% Check arguments
  if ~any(nargin() == [ 1, 2 ])
    usage("[ this ] = BBOCC(divergence [, opts])");
  endif

  %% This object
  this = struct();

  %% Divergence
  this.divergence = divergence;

  %% Size ratio
  %% Default -> 0.1
  this.size_ratio = getfielddef(opts, "size_ratio", 0.1);

  %% Maximum number of iterations
  %% Default -> 100
  this.max_iterations = getfielddef(opts, "max_iterations", 100);

  %% Change threshold
  %% Default -> 1
  this.change_threshold = getfielddef(opts, "change_threshold", 1);

  %% Centroid finder
  %% Default -> Raw
  if ~isfield(opts, "centroid_finder")
    this.centroid_finder = RawCentroids();

  elseif ~isobject(opts.centroid_finder)
    opts.centroid_finder = tolower(opts.centroid_finder);
    switch opts.centroid_finder
      case "raw"
	this.centroid_finder = RawCentroids();
      case "smooth"
	this.centroid_finder = SmoothCentroids();
      default
	error("Bad centroid finder '%s'", opts.centroid_finder);
    endswitch

  else
    this.centroid_finder = opts.centroid_finder;
  endif

  %% Verbose
  %% Default -> false
  this.verbose = getfielddef(opts, "verbose", false());

  %% Bless
  %% And add inheritance
  this = class(this, "BBOCC", ...
	       Simple());
endfunction
