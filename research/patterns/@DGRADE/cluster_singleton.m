%% -*- mode: octave; -*-

%% Density Gradient Enumeration (DGRADE)
%% Clustering helper function

%% Author: Edgar Gonzalez

function [ hard_expec, centroids, radius ] = ...
      cluster_singleton(this, n_samples, target_size, data)
  %% Single centroid
  centroids = mean(data, 2);

  %% Divergence from centroid
  divs = apply(this.divergence, centroids, data);
  sort_divs = sort(divs);

  %% Radius and cluster
  radius  = sort_divs(target_size);
  cluster = find(divs <= radius);

  %% Hard expectation
  hard_expec = zeros(1, n_samples);
  hard_expec(cluster) = 1;
endfunction
