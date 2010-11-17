%% -*- mode: octave; -*-

%% Linear interpolator model
%% Inverse apply function

%% Author: Edgar Gonzalez

function [ input ] = inverse(this, output)

  %% Check arguments
  if nargin() ~= 2
    usage("[ input ] = @LinearInterModel/inverse(this, output)");
  endif

  %% Input
  input = this.low_in + (output - this.low) / this.step;

  %% Saturate
  input(input < this.low_in ) = nan;
  input(input > this.high_in) = nan;
endfunction
