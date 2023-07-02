%% -*- mode: octave; -*-

%% Logarithmic interpolator
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = LogInterpolator(low = 0.0, high = 1.0)

  %% Check arguments
  if ~any(nargin() == [ 0, 2 ])
    usage("[ this ] = LogInterpolator([low, high])");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.low  = low;
  this.high = high;

  %% Bless
  %% And add inheritance
  this = class(this, "LogInterpolator", ...
               Simple());
endfunction
