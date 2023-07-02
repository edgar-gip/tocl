%% -*- mode: octave; -*-

%% 1D Gaussian distribution splitter
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = Gaussian1DSplit(opts = struct())

  %% Check arguments
  if ~any(nargin() == [ 0, 1 ])
    usage("[ this ] = Gaussian1D(opts = struct())");
  endif

  %% This object
  this = struct();

  %% Alpha prior
  %% Default -> 1
  this.alpha_prior = getfielddef(opts, "alpha_prior", 1);

  %% Verbose
  %% Default -> false
  this.verbose = getfielddef(opts, "verbose", false());

  %% Bless
  %% And add inheritance
  this = class(this, "Gaussian1DSplit", ...
               Simple());
endfunction
