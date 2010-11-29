%% -*- mode: octave; -*-

%% Null interpolator
%% Apply function

%% Author: Edgar Gonzalez

function [ output, model, info ] = apply(this, input)

  %% Check arguments
  if nargin() ~= 2
    usage("[ output, model, info ] = @NullInterpolator/apply(this, input)");
  endif

  %% Output is input
  output = input;

  %% Model
  model = NullInterModel();

  %% Empty information
  info = struct();
endfunction
