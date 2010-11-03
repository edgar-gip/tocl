%% -*- mode: octave; -*-

%% Logarithmic interpolator
%% Map function

%% Author: Edgar Gonzalez

function [ output, info ] = map(this, input)

  %% Input must be given
  if nargin() ~= 2
    usage("[ output, info ] = @LogInterpolator/apply(this, input)");
  endif

  %% Find bounds
  min_in = min(min(input));
  max_in = max(max(input));

  %% Range is null?
  if min_in == max_in
    %% Output is the average of high and low
    output = (this.low + this.high) / 2 * ones(size(input));

  else
    %% Map
    output = ...
	this.low + (this.high - this.low) * ...
	           log(input / min_in) / log(max_in / min_in);
  endif

  %% Information
  info = struct();
  info.min = min_in;
  info.max = max_in;
endfunction
