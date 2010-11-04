%% -*- mode: octave; -*-

%% Constant interpolator model
%% Apply function

%% Author: Edgar Gonzalez

function [ output ] = apply(this, input)

  %% Check arguments
  if nargin() ~= 2
    usage("[ output ] = @ConstInterModel/apply(this, input)");
  endif

  %% Output
  output = this.value * ones(size(input));
endfunction
