%% -*- mode: octave; -*-

%% Logarithmic interpolator model
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = LogInterModel(low, high, low_in, high_in, log_denom)

  %% Check arguments
  if nargin() ~= 5
    usage("[ this ] = LogInterModel(low, high, low_in, high_in, log_denom)");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.low       = low;
  this.high      = high;
  this.low_in    = low_in;
  this.high_in   = high_in;
  this.log_denom = log_denom;

  %% Bless
  %% And add inheritance
  this = class(this, "LogInterModel", ...
               Simple());
endfunction
