%% -*- mode: octave; -*-

%% Logarithmic interpolator model
%% Inverse apply function

%% Author: Edgar Gonzalez

function [ input ] = inverse(this, output)

  %% Check arguments
  if nargin() ~= 2
    usage("[ input ] = @LogInterModel/inverse(this, output)");
  endif

  %% Input
  input = ...
      this.low_in * exp(this.log_denom * (output - this.low) / ...
			(this.high - this.low));

  %% Saturate
  input(input < this.low_in)  = nan;
  input(input > this.high_in) = nan;
endfunction
