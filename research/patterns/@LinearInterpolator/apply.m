%% -*- mode: octave; -*-

%% Linear interpolator
%% Apply function

%% Author: Edgar Gonzalez

function [ output, model, info ] = apply(this, input)

  %% Check arguments
  if nargin() ~= 2
    usage("[ output, model, info ] = @LinearInterpolator/apply(this, input)");
  endif

  %% Find bounds
  low_in  = min(min(input));
  high_in = max(max(input));

  %% Range is null?
  if low_in == high_in
    %% Output is the average of high and low
    mean   = (this.low + this.high) / 2;
    output = mean * ones(size(input));

    %% Model
    model = ConstInterModel(low_in, mean);

  else
    %% Step
    step = (this.high - this.low) / (high_in - low_in);

    %% Map
    output = this.low + step * (input - low_in);

    %% Model
    model = LinearInterModel(this.low, this.high, low_in, high_in, step);
  endif

  %% Information
  info = struct();
  info.low  = low_in;
  info.high = high_in;
endfunction
