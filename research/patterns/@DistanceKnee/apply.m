%% -*- mode: octave; -*-

%% Distance Knee Finder
%% Apply function

%% Author: Edgar Gonzalez

function [ mid, mid_idx ] = apply(this, input)

  %% Check arguments
  if nargin() ~= 2
    usage("[ mid, mid_idx ] = @DistanceKnee/apply(this, input)");
  endif

  %% Size
  n_data = length(input);

  %% Low and high
  low  = input(n_data);
  high = input(1);

  %% Find the distance
  input_n = (input - low) ./ (high - low);
  idx_n   = (0 : (n_data - 1)) ./ (n_data - 1);
  dist    = input_n .* input_n + idx_n .* idx_n;

  %% Minimum point
  [ min_dist, min_idx ] = min(dist);

  %% Cut point
  mid = input(min_idx);
endfunction
