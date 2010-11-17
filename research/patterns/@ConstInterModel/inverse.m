%% -*- mode: octave; -*-

%% Constant interpolator model
%% Inverse aply function

%% Author: Edgar Gonzalez

function [ input ] = inverse(this, output)

  %% Check arguments
  if nargin() ~= 2
    usage("[ input ] = @ConstInterModel/inverse(this, output)");
  endif

  %% Input
  input = this.value_in * ones(size(output));
  input(output ~= this.value) = nan;
endfunction
