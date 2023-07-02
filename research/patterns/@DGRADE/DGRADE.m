%% -*- mode: octave; -*-

%% Density Gradient Enumeration (DGRADE)
%% From:
%%   Joydeep Gosh, Gunjan Gupta
%%   "Bregman Bubble Clustering: A Robust Framework for Mining Dense
%%    Clusters" in
%%   Dawn Holmes, Lakhmi C. Jain (Eds.)
%%   "DATA MINING: Foundations and Intelligent Paradigms"
%%   Springer, 2011

%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = DGRADE(divergence, opts = struct())

  %% Check arguments
  if ~any(nargin() == [ 1, 2 ])
    usage("[ this ] = DGRADE(divergence [, opts])");
  endif

  %% This object
  this = struct();

  %% Divergence
  this.divergence = divergence;

  %% Size ratio
  %% Default -> 0.1
  this.size_ratio = getfielddef(opts, "size_ratio", 0.1);

  %% Smoothing parameter
  %% Default -> 5
  this.s_one = getfielddef(opts, "s_one", 5);

  %% Verbose
  %% Default -> false
  this.verbose = getfielddef(opts, "verbose", false());

  %% Bless
  %% And add inheritance
  this = class(this, "DGRADE", ...
               Simple());
endfunction
