%% -*- mode: octave; -*-

%% Exponential interpolator
%% Apply function

%% Author: Edgar Gonzalez

function [ output, model, info ] = apply(this, input)

  %% Check arguments
  if nargin() ~= 2
    usage("[ output, model, info ] = @ExpInterpolator/apply(this, input)");
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
    %% Map
    exp_denom = exp(this.convexity * (high_in - low_in)) - 1;
    output = ...
	this.low + (this.high - this.low) * ...
	           (exp(this.convexity * (input  - low_in)) - 1) / ...
	            exp_denom;

    %% Model
    model = ExpInterModel(this.low, this.high, this.convexity, ...
			  low_in, high_in, exp_denom);
  endif

  %% Information
  info = struct();
  info.low  = low_in;
  info.high = high_in;
endfunction
