%% -*- mode: octave; -*-

%% Knee-detection interpolator
%% Apply function

%% Author: Edgar Gonzalez

function [ output, model, info ] = apply(this, input)

  %% Check arguments
  if nargin() ~= 2
    usage("[ output, model, info ] = @KneeInterpolator/apply(this, input)");
  endif

  %% Sort input
  n_elems = numel(input);
  sorted  = sort(reshape(input, 1, n_elems), "descend");
  high_in = sorted(1);
  low_in  = sorted(n_elems);

  %% Range is null?
  if low_in == high_in
    %% Cut point
    cut = low_in;

    %% Output is the average of high and low
    mean   = (this.low + this.high) / 2;
    output = mean * ones(size(input));

    %% Model
    model = ConstInterModel(mean);

  else
    %% Find the distance
    sorted_n = (sorted - low_in) ./ (high_in - low_in);
    idx_n    = (0 : (n_elems - 1)) ./ (n_elems - 1);
    dist     = sorted_n .* sorted_n + idx_n .* idx_n;

    %% Minimum point
    [ min_dist, min_idx ] = min(dist);

    %% Cut point
    cut = sorted(min_idx);

    %% Low and high parts
    low_part  = input <= cut;
    high_part = input >= cut;

    %% Interpolate both parts
    [ low_output,  low_model  ] = apply(this.low_inter,  input(low_part));
    [ high_output, high_model ] = apply(this.high_inter, input(high_part));

    %% Generate an output
    output(low_part)  = low_output;
    output(high_part) = high_output;

    %% Model
    model = KneeInterModel(cut, low_model, high_model);
  endif

  %% Information
  info = struct();
  info.low  = low_in;
  info.cut  = cut;
  info.high = high_in;
endfunction
