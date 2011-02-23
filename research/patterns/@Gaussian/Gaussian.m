%% -*- mode: octave; -*-

%% Gaussian distribution clustering
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = Gaussian(opts = struct())

  %% Check arguments
  if ~any(nargin() == [ 0, 1 ])
    usage("[ this ] = Gaussian([opts])");
  endif

  %% This object
  this = struct();

  %% Alpha prior
  %% Default -> 1
  this.alpha_prior = getfielddef(opts, "alpha_prior", 1);

  %% Minimum covariance
  %% Default -> eps
  this.min_covar = getfielddef(opts, "min_covar", eps);

  %% Verbose
  %% Default -> false
  this.verbose = getfielddef(opts, "verbose", false());

  %% Bless
  %% And add inheritance
  this = class(this, "Gaussian", ...
	       EM(opts));
endfunction
