%% -*- mode: octave; -*-

%% Logarithmic interpolator
%% Apply function

%% Author: Edgar Gonzalez

function [ output, model, info ] = apply(this, input)

  %% Check arguments
  if nargin() ~= 2
    usage("[ output, model, info ] = @LogInterpolator/apply(this, input)");
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
    model = ConstInterModel(mean);

  else
    %% Map
    log_denom  = log(high_in / low_in);
    output     = ...
	this.low + (this.high - this.low) * ...
	           log(input / low_in) / log_denom;

    %% Model
    model = LogInterModel(this.low, this.high, low_in, log_denom);
  endif

  %% Information
  info = struct();
  info.low  = low_in;
  info.high = high_in;
endfunction
