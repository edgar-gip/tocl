%% -*- mode: octave; -*-

%% Knee-detection interpolator model
%% Apply function

%% Author: Edgar Gonzalez

function [ output ] = apply(this, input)

  %% Check arguments
  if nargin() ~= 2
    usage("[ output ] = @KneeInterModel/apply(this, input)");
  endif

  %% Low and high parts
  low_part  = input <= this.cut;
  high_part = input >= this.cut;

  %% Interpolate both parts
  low_output  = apply(this.low_model,  input(low_part));
  high_output = apply(this.high_model, input(high_part));

  %% Generate an output
  output(low_part)  = low_output;
  output(high_part) = high_output;
endfunction
