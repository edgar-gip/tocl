%% -*- mode: octave; -*-

%% Sequential Expectation-Maximization clustering
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = SeqEM(clusterers, opts = struct())

  %% Check arguments
  if ~any(nargin() == [ 1, 2 ])
    usage("[ this ] = SeqEM(clusterers [, opts])");
  endif

  %% This object
  this = struct();

  %% Clusterers
  this.clusterers = clusterers;

  %% Final model index
  %% Default -> Last one
  this.final_model = getfielddef(opts, "final_model", length(clusterers));

  %% Verbose
  %% Default -> false
  this.verbose = getfielddef(opts, "verbose", false());

  %% Bless
  this = class(this, "SeqEM",
	       Simple());
endfunction
