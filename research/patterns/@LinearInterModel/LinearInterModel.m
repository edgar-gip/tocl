%% -*- mode: octave; -*-

%% Linear interpolator model
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = LinearInterModel(low, high, low_in, high_in, step)

  %% Check arguments
  if nargin() ~= 5
    usage("[ this ] = LinearInterModel(low, high, low_in, high_in, step)");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.low     = low;
  this.high    = high;
  this.low_in  = low_in;
  this.high_in = high_in;
  this.step    = step;

  %% Bless
  %% And add inheritance
  this = class(this, "LinearInterModel", ...
	       Simple());
endfunction
