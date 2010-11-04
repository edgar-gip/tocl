%% -*- mode: octave; -*-

%% Exponential interpolator
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = ExpInterpolator(low = 0.0, high = 1.0, convexity = 1.0)

  %% Check arguments
  if ~any(nargin() == [ 0, 2, 3 ])
    usage("[ this ] = ExpInterpolator([low, high [, convexity]])");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.low       = low;
  this.high      = high;
  this.convexity = convexity;

  %% Bless
  %% And add inheritance
  this = class(this, "ExpInterpolator", ...
	       Simple());
endfunction
