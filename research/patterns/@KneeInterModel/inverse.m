%% -*- mode: octave; -*-

%% Knee-detection interpolator model
%% Inverse apply function

%% Author: Edgar Gonzalez

function [ input ] = inverse(this, output)

  %% Check arguments
  if nargin() ~= 2
    usage("[ input ] = @KneeInterModel/inverse(this, output)");
  endif

  %% Low and high parts
  low_part  = output <= this.mid;
  high_part = output >= this.mid;

  %% Interpolate both parts
  low_input  = inverse(this.low_model,  output(low_part));
  high_input = inverse(this.high_model, output(high_part));

  %% Generate an input
  input(low_part)  = low_input;
  input(high_part) = high_input;
endfunction
