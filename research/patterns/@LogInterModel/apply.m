%% -*- mode: octave; -*-

%% Logarithmic interpolator model
%% Apply function

%% Author: Edgar Gonzalez

function [ output ] = apply(this, input)

  %% Check arguments
  if nargin() ~= 2
    usage("[ output ] = @LogInterModel/apply(this, input)");
  endif

  %% Output
  output = ...
      this.low + (this.high - this.low) * ...
                 log(input / this.low_in) / this.log_denom;

  %% Saturate
  output(output < this.low ) = this.low;
  output(output > this.high) = this.high;
endfunction
