%% -*- mode: octave; -*-

%% 1D Gaussian distribution clustering (with noise cluster)
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = Gaussian1DNoise(opts = struct())

  %% Check arguments
  if ~any(nargin() == [ 0, 1 ])
    usage("[ this ] = Gaussian1DNoise(opts = struct())");
  endif

  %% This object
  this = struct();

  %% Alpha prior
  %% Default -> 1
  this.alpha_prior = getfielddef(opts, "alpha_prior", 1);

  %% Bless
  %% And add inheritance
  this = class(this, "Gaussian1DNoise", ...
	       Gaussian1D(opts));
endfunction
