%% -*- mode: octave; -*-

%% Bregman Bubble Clustering
%% From:
%%   Gunjan Gupta, Joydeep Gosh
%%   "Bregman Bubble Clustering: A Robust, Scalable Framework for
%%    Locating Multiple, Dense Regions in Data"
%%   International Conference on Data Mining (ICDM), 2006

%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = BBC(divergence, opts = struct())

  %% Check arguments
  if ~any(nargin() == [ 1, 2 ])
    usage("[ this ] = BBC(divergence [, opts])");
  endif

  %% This object
  this = struct();

  %% Divergence
  this.divergence = divergence;

  %% Size ratio
  %% Default -> 0.1
  this.size_ratio = getfielddef(opts, "size_ratio", 0.1);

  %% Change threshold
  %% Default -> 1
  this.change_threshold = getfielddef(opts, "change_threshold", 1);

  %% Verbose
  %% Default -> false
  this.verbose = getfielddef(opts, "verbose", false());

  %% Bless
  %% And add inheritance
  this = class(this, "BBC", ...
               Simple());
endfunction
