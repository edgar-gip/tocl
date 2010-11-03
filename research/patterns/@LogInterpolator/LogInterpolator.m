%% -*- mode: octave; -*-

%% Logarithmic interpolator
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = LogInterpolator(low, high)

  %% Both values or none
  if nargin() ~= 0 && nargin() ~= 2
    usage("[ this ] = LogInterpolator([low, high])");
  endif

  %% This object
  this = struct();

  %% Set fields
  if nargin() == 0
    this.low       = 0.0;
    this.high      = 1.0;
  else
    this.low  = low;
    this.high = high;
  endif

  %% Bless
  %% And add inheritance
  this = class(this, "LogInterpolator", ...
	       Simple());
endfunction
