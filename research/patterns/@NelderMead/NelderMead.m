%% -*- mode: octave; -*-

%% Nelder-Mead Downhill Simplex in Multidimensions
%% Algorithm 10.5 from
%%   Numerical Recipes

%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = NelderMead(opts = struct())

  %% Check arguments
  if ~any(nargin() == [ 0, 1 ])
    usage("[ this ] = NelderMead([opts])");
  endif

  %% This object
  this = struct();

  %% Starting delta
  %% Default -> 2.0;
  this.delta = getfielddef(opts, "delta", 2.0);

  %% Maximum number of evaluations
  %% Default -> 1000
  this.max_eval = getfielddef(opts, "max_eval", 1000);

  %% Tolerance
  %% Default -> 1e-6
  this.tolerance = getfielddef(opts, "tolerance", 1e-6);

  %% Callback
  %% Default -> none
  this.callback = getfielddef(opts, "callback", []);

  %% Bless
  %% And add inheritance
  this = class(this, "NelderMead", ...
	       Simple());
endfunction
