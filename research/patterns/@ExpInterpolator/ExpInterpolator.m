%% -*- mode: octave; -*-

%% Exponential interpolator
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = ExpInterpolator(low, high, convexity)

  %% Both values or none
  if nargin() ~= 0 && nargin() ~= 2 && nargin() ~= 3
    usage("[ this ] = ExpInterpolator([low, high [, convexity]])");
  endif

  %% This object
  this = struct();

  %% Set fields
  if nargin() == 0
    this.low       = 0.0;
    this.high      = 1.0;
    this.convexity = 1.0;
  else
    this.low  = low;
    this.high = high;
    if nargin () == 2
      this.convexity = 1.0;
    else
      this.convexity = convexity;
    endif
  endif

  %% Bless
  %% And add inheritance
  this = class(this, "ExpInterpolator", ...
	       Simple());
endfunction
