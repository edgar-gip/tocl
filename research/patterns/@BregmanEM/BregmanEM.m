%% -*- mode: octave; -*-

%% Bregman Divergence EM-like clustering
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = BregmanEM(divergence, opts = struct())

  %% Check arguments
  if ~any(nargin() == [ 1, 2 ])
    usage("[ this ] = BregmanEM(divergence [, opts])");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.divergence = divergence;

  %% Alpha prior
  %% Default -> 1
  this.alpha_prior = getfielddef(opts, "alpha_prior", 1);

  %% Beta (scaling)
  %% Default -> 1
  this.beta = getfielddef(opts, "beta", 1);

  %% Bless
  %% And add inheritance
  this = class(this, "BregmanEM", ...
               EM(opts));
endfunction
