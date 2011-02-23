%% -*- mode: octave; -*-

%% Expectation-Maximization clustering
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = EM(opts = struct())

  %% Check arguments
  if ~any(nargin() == [ 0, 1 ])
    usage("[ this ] = EM([ opts ])");
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
  this = class(this, "EM",
	       Simple());
endfunction
