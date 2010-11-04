%% -*- mode: octave; -*-

%% Exponential interpolator model
%% Apply function

%% Author: Edgar Gonzalez

function [ output ] = apply(this, input)

  %% Check arguments
  if nargin() ~= 2
    usage("[ output ] = @ExpInterModel/apply(this, input)");
  endif

  %% Output
  output = ...
      this.low + (this.high - this.low) * ...
                 (exp(this.convexity * (input  - this.low_in)) - 1) / ...
                  this.exp_denom;

  %% Saturate
  output = max([this.low, min([this.high, output])]);
endfunction
