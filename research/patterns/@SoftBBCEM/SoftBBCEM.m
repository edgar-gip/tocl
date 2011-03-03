%% -*- mode: octave; -*-

%% Soft Bregman Bubble Clustering
%% From:
%%   Gunjan Gupta, Joydeep Gosh
%%   "Bregman Bubble Clustering: A Robust, Scalable Framework for
%%    Locating Multiple, Dense Regions in Data"
%%   International Conference on Data Mining (ICDM), 2006

%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = SoftBBCEM(divergence, opts = struct())

  %% Check arguments
  if ~any(nargin() == [ 1, 2 ])
    usage("[ this ] = SoftBBCEM(divergence [, opts])");
  endif

  %% This object
  this = struct();

  %% Divergence
  this.divergence = divergence;

  %% Alpha prior
  %% Default -> 1
  this.alpha_prior = getfielddef(opts, "alpha_prior", 1);

  %% Alpha for the background component
  %% Default -> nan (adjustable)
  this.bg_alpha = getfielddef(opts, "bg_alpha", nan);

  %% Beta (scaling)
  %% Default -> 1
  this.beta = getfielddef(opts, "beta", 1);

  %% Bless
  %% And add inheritance
  this = class(this, "SoftBBCEM", ...
	       EM(opts));
endfunction
