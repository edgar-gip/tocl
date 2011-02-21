%% -*- mode: octave; -*-

%% Criterion-function based clustering
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = CriterionClusterer(clusterer, criterion, opts = struct())

  %% Check arguments
  if ~any(nargin() == [ 2, 3 ])
    usage("[ this ] = CriterionClusterer(clusterer, criterion [, opts])");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.clusterer = clusterer;
  this.criterion = criterion;

  %% Minimum k
  %% Default -> 1
  this.min_k = getfielddef(opts, "min_k", 1);

  %% Maximum k
  %% Default -> 1.0 (all)
  this.max_k = getfielddef(opts, "max_k", 1.0);

  %% Repeats
  %% Default -> 5
  this.repeats = getfielddef(opts, "repeats", 5);

  %% Verbose
  %% Default -> false
  this.verbose = getfielddef(opts, "verbose", false());

  %% Bless
  %% And add inheritance
  this = class(this, "CriterionClusterer",
	       Simple());
endfunction
