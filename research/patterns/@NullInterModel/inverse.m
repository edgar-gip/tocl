%% -*- mode: octave; -*-

%% Null interpolator model
%% Inverse apply function

%% Author: Edgar Gonzalez

function [ input ] = inverse(this, output)

  %% Check arguments
  if nargin() ~= 2
    usage("[ input ] = @NullInterModel/inverse(this, output)");
  endif

  %% Input is output
  input = output;
endfunction
