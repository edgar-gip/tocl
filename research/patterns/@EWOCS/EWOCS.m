%% -*- mode: octave; -*-

%% Ensemble Weak One-Class Scoring
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = EWOCS(clusterer, opts = struct())

  %% Check arguments
  if ~any(nargin() == [ 1, 2 ])
    usage("[ this ] = EWOCS(clusterer [, opts])");
  endif

  %% This object
  this = struct();

  %% Clusterer
  this.clusterer = clusterer;

  %% Ensemble size
  %% Default -> 100
  this.ensemble_size = getfielddef(opts, "ensemble_size", 100);

  %% Maximum number of clusters
  %% Default -> 100
  this.max_clusters = getfielddef(opts, "max_clusters", 100);

  %% Verbose
  %% Default -> false
  this.verbose = getfielddef(opts, "verbose", false());

  %% Scoring function name
  %% Default -> NSize
  if ~isfield(opts, "score_function")
    this.score_function = NSizeCSF();

  elseif ~isobject(opts.score_function)
    opts.score_function = tolower(opts.score_function);
    switch opts.score_function
      case "dense"
	this.score_function = DenseCSF();
      case "ndense"
	this.score_function = NDenseCSF();
      case "nsize"
	this.score_function = NSizeCSF();
      case "radius"
	this.score_function = RadiusCSF();
      case "size"
	this.score_function = SizeCSF();
    endswitch

  else
    this.score_function = opts.score_function;
  endif

  %% Interpolator
  %% Default -> Linear
  if ~isfield(opts, "interpolator")
    this.interpolator = LinearInterpolator();

  elseif ~isobject(opts.interpolator)
    opts.interpolator = tolower(opts.interpolator);
    switch opts.interpolator
      case "exp"
	this.interpolator = ExpInterpolator();
      case "linear"
	this.interpolator = LinearInterpolator();
      case "log"
	this.interpolator = LogInterpolator();
    endswitch

  else
    this.interpolator = opts.interpolator;
  endif

  %% Bless
  %% And add inheritance
  this = class(this, "EWOCS", ...
	       Simple());
endfunction
