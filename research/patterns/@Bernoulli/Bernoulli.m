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

  %% Alpha prior
  %% Default -> 1
  this.alpha_prior = getfielddef(opts, "alpha_prior", 1);

  %% Theta prior
  %% Default -> 1
  this.theta_prior = getfielddef(opts, "theta_prior", 1);

  %% Bless
  %% And add inheritance
  this = class(this, "Bernoulli", ...
               EM(opts));
endfunction
