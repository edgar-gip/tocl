%% -*- mode: octave; -*-

%% Linear interpolator model
%% Apply function

%% Author: Edgar Gonzalez

function [ output ] = apply(this, input)

  %% Check arguments
  if nargin() ~= 2
    usage("[ output ] = @LinearInterModel/apply(this, input)");
  endif

  %% Output
  output = this.low + this.step * (input - this.low_in);

  %% Saturate
  output(output < this.low ) = this.low;
  output(output > this.high) = this.high;
endfunction
