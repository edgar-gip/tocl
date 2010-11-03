%% -*- mode: octave; -*-

%% Linear interpolator
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = LinearInterpolator(low, high)

  %% Both values or none
  if nargin() ~= 0 && nargin() ~= 2
    usage("[ this ] = LinearInterpolator([low, high])");
  endif

  %% This object
  this = struct();

  %% Set fields
  if nargin() == 0
    this.low  = 0.0;
    this.high = 1.0;
  else
    this.low  = low;
    this.high = high;
  endif

  %% Bless
  %% And add inheritance
  this = class(this, "LinearInterpolator", ...
	       Simple());
endfunction
