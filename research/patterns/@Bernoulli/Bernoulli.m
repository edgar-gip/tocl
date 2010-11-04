%% -*- mode: octave; -*-

%% Bernoulli distribution clustering
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = Bernoulli(opts = struct())

  %% Check arguments
  if ~any(nargin() == [ 0, 1 ])
    usage("[ this ] = Bernoulli(opts = struct())");
  endif

  %% This object
  this = struct();

  %% Maximum number of iterations
  %% Default -> 100
  this.em_iterations = getfielddef(opts, "em_iterations", 100);

  %% Variance threshold
  %% Default -> 1e-6
  this.em_threshold = getfielddef(opts, "em_threshold", 1e-6);

  %% Alpha prior
  %% Default -> 1
  this.alpha_prior = getfielddef(opts, "alpha_prior", 1);

  %% Theta prior
  %% Default -> 1
  this.theta_prior = getfielddef(opts, "theta_prior", 1);

  %% Verbose
  %% Default -> false
  this.verbose = getfielddef(opts, "verbose", false());

  %% Bless
  %% And add inheritance
  this = class(this, "Bernoulli", ...
	       Simple());
endfunction
