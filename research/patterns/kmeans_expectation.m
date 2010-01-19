%% -*- mode: octave; -*-

%% k-Means clustering
%% Expectation

%% Author: Edgar Gonzalez

function [ expec, sum_dist ] = kmeans_expectation(data, model, auto_data)

  %% Sizes
  n_data = size(data, 2);
  k      = size(model.centroids, 2);

  %% Is the auto-dot-product matrix given?
  if nargin() < 3
    auto_data = sum(data .* data); % 1 * n_data
  endif

  %% Find the auto-dot-product matrix for the centroids
  centroids      = model.centroids;
  auto_centroids = sum(centroids .* centroids); % 1 * k

  %% d(x,y) = x · x + y · y - 2 · x · y
  distance = ones(k, 1) * auto_data + auto_centroids' * ones(1, n_data) ...
           - 2 * centroids' * data; % k * n_data

  %% Find the minimum distance at each point, and assign it
  [ min_dist, min_cl ] = min(distance);

  %% R
  expec    = sparse(min_cl, 1 : n_data, ones(1, n_data), k, n_data);
  sum_dist = sum(min_dist);
endfunction
