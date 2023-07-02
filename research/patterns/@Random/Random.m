%% -*- mode: octave; -*-

%% Truly random clustering
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = Random(opts = struct())

  %% Check arguments
  if ~any(nargin() == [ 0, 1 ])
    usage("[ this ] = Random([opts])");
  endif

  %% This object
  this = struct();

  %% Concentration for Dirichlet distribution
  %% Default -> 1.0
  this.concentration = getfielddef(opts, "concentration", 1.0);

  %% Verbose
  %% Default -> false
  this.verbose = getfielddef(opts, "verbose", false());

  %% Bless
  %% And add inheritance
  this = class(this, "Random", ...
               Simple());
endfunction
