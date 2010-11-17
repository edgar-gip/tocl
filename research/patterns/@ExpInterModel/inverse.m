%% -*- mode: octave; -*-

%% Exponential interpolator model
%% Inverse apply function

%% Author: Edgar Gonzalez

function [ input ] = inverse(this, output)

  %% Check arguments
  if nargin() ~= 2
    usage("[ input ] = @ExpInterModel/inverse(this, output)");
  endif

  %% Input
  input = ...
      this.low_in + ...
      log(1 + this.exp_denom * (output - this.low) / ...
	  (this.high - this.low)) / this.convexity;

  %% Saturate
  input(input < this.low_in ) = nan;
  input(input > this.high_in) = nan;
endfunction
