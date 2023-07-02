%% -*- mode: octave; -*-

%% Gaussian distribution EM clustering
%% Axis-aligned variance version
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = AlignedGaussianEM(opts = struct())

  %% Check arguments
  if ~any(nargin() == [ 0, 1 ])
    usage("[ this ] = AlignedGaussianEM([opts])");
  endif

  %% This object
  this = struct();

  %% Alpha prior
  %% Default -> 1
  this.alpha_prior = getfielddef(opts, "alpha_prior", 1);

  %% Minimum covariance
  %% Default -> eps
  this.min_covar = getfielddef(opts, "min_covar", eps);

  %% Bless
  %% And add inheritance
  this = class(this, "AlignedGaussianEM", ...
               EM(opts));
endfunction
