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
  this.size_ratio = getfielddef(opts, "size_ratio", 100);

  %% Verbose
  %% Default -> false
  this.verbose = getfielddef(opts, "verbose", false());

  %% Bless
  %% And add inheritance
  this = class(this, "BBOCC", ...
	       Simple());
endfunction
