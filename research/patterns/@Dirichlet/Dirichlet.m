%% -*- mode: octave; -*-

%% Dirichlet distribution clustering
%% Main procedure

%% Author: Edgar Gonzalez

function [ this ] = Dirichlet(opts)

  %% Options given?
  if nargin() < 1
    opts = struct();
  endif

  %% This object
  this = struct();

  %% Maximum number of iterations
  %% Default -> 100
  this.em_iterations = getfielddef(opts, "em_iterations", 100);

  %% Variance threshold
  %% Default -> 1e-6
  this.em_threshold = getfielddef(opts, "em_threshold", 1e-6);

  %% Verbose
  %% Default -> false
  this.verbose = getfielddef(opts, "verbose", false());

  %% Bless
  %% And add inheritance
  this = class(this, "Dirichlet", ...
	       Simple());
endfunction
