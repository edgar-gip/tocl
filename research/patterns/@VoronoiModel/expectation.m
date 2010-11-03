%% -*- mode: octave; -*-

%% Voronoi clustering
%% Expectation

%% Author: Edgar Gonzalez

function [ expec, log_like ] = expectation(this, data)
  %% Number of data
  n_data = size(data, 2);

  %% Find the distance
  distances = apply(this.distance, this.centroids, data);

  %% Hard or soft?
  if isfinite(this.soft_alpha)
    %% Soft
    expec = distance_probability(this.soft_alpha, -distances);
  else
    %% Hard
    expec = distance_winner(-distances);
  endif

  %% Log-like is not considered here
  log_like = nan;
endfunction
