%% -*- mode: octave; -*-

%% Linear interpolator
%% Map function

%% Author: Edgar Gonzalez

function [ output, info ] = map(this, input)

  %% Input must be given
  if nargin() ~= 2
    usage("[ output, info ] = @LinearInterpolator/apply(this, input)");
  endif

  %% Find bounds
  min_in = min(min(input));
  max_in = max(max(input));

  %% Range is null?
  if min_in == max_in
    %% Output is the average of high and low
    output = (this.low + this.high) / 2 * ones(size(input));

  else
    %% Step
    step = (this.high - this.low) / (max_in - min_in);

    %% Map
    output = this.low + step * (input - min_in);
  endif

  %% Information
  info = struct();
  info.min = min_in;
  info.max = max_in;
endfunction
