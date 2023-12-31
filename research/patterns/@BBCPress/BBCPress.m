%% -*- mode: octave; -*-

%% Bregman Bubble Clustering (with Pressurization)
%% From:
%%   Gunjan Gupta, Joydeep Gosh
%%   "Bregman Bubble Clustering: A Robust, Scalable Framework for
%%    Locating Multiple, Dense Regions in Data"
%%   International Conference on Data Mining (ICDM), 2006

%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = BBCPress(divergence, opts = struct())

  %% Check arguments
  if ~any(nargin() == [ 1, 2 ])
    usage("[ this ] = BBCPress(divergence [, opts])");
  endif

  %% This object
  this = struct();

  %% Divergence
  this.divergence = divergence;

  %% Size ratio
  %% Default -> 0.1
  this.size_ratio = getfielddef(opts, "size_ratio", 0.1);

  %% Pressurization decay
  %% Default -> 0.75
  this.press_decay = getfielddef(opts, "press_decay", 0.75);

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
      otherwise
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
  this = class(this, "BBCPress", ...
               Simple());
endfunction
