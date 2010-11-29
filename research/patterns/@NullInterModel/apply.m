%% -*- mode: octave; -*-

%% Null interpolator model
%% Apply function

%% Author: Edgar Gonzalez

function [ output ] = apply(this, input)

  %% Check arguments
  if nargin() ~= 2
    usage("[ output ] = @NullInterModel/apply(this, input)");
  endif

  %% Output is input
  output = input;
endfunction
