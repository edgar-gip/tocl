%% -*- mode: octave; -*-

%% k-Minority Detection
%% From:
%%   Shin Ando
%%   "Clustering Needles in a Haystack: An Information Theoretic
%%    Analysis of Minority and Outlier Detection"
%%   International Conference on Data Mining (ICDM), 2007

%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = KMD(fg_component, bg_component, opts = struct())

  %% Check arguments
  if ~any(nargin() == [ 1, 2, 3 ])
    usage("[ this ] = KMD(fg_component [, bg_component [, opts]])");
  endif

  %% This object
  this = struct();

  %% Foreground component
  this.fg_component = fg_component;

  %% Background component
  if nargin() < 2 || isempty(bg_component)
    this.bg_component = this.fg_component;
  else
    this.bg_component = bg_component;
  endif

  %% Minimum size
  %% Default -> 0.02
  this.min_size = getfielddef(opts, "min_size", 0.02);

  %% Starting size
  %% Default -> 0.1
  this.start_size = getfielddef(opts, "start_size", 0.1);

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
  this = class(this, "KMD", ...
	       Simple());
endfunction
