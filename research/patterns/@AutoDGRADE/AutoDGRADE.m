%% -*- mode: octave; -*-

%% Density Gradient Enumeration (DGRADE) with automatical s_one tuning.
%% Section 9.3, scheme 3 from:
%%   Joydeep Gosh, Gunjan Gupta
%%   "Bregman Bubble Clustering: A Robust Framework for Mining Dense
%%    Clusters" in
%%   Dawn Holmes, Lakhmi C. Jain (Eds.)
%%   "DATA MINING: Foundations and Intelligent Paradigms"
%%   Springer, 2011

%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = AutoDGRADE(divergence, opts = struct())

  %% Check arguments
  if ~any(nargin() == [ 1, 2 ])
    usage("[ this ] = AutoDGRADE(divergence [, opts])");
  endif

  %% This object
  this = struct();

  %% Divergence
  this.divergence = divergence;

  %% Size ratio
  %% Default -> 0.1
  this.size_ratio = getfielddef(opts, "size_ratio", 0.1);

  %% Verbose
  %% Default -> false
  this.verbose = getfielddef(opts, "verbose", false());

  %% Bless
  %% And add inheritance
  this = class(this, "AutoDGRADE", ...
               Simple());
endfunction
