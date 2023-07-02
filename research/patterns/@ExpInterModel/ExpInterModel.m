%% -*- mode: octave; -*-

%% Exponential interpolator model
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = ExpInterModel(low, high, convexity, ...
                                  low_in, high_in, exp_denom)

  %% Check arguments
  if nargin() ~= 6
    usage(cstrcat("[ this ] = ExpInterModel(low, high, convexity,", ...
                  " low_in, high_in, exp_denom)"));
  endif

  %% This object
  this = struct();

  %% Set fields
  this.low       = low;
  this.high      = high;
  this.convexity = convexity;
  this.low_in    = low_in;
  this.high_in   = high_in;
  this.exp_denom = exp_denom;

  %% Bless
  %% And add inheritance
  this = class(this, "ExpInterModel", ...
               Simple());
endfunction
