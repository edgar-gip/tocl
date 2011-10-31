%% -*- mode: octave; -*-

function [ affinity ] = perfect_affinity(alpha)
  %% Number of clusters
  n_clusters = length(alpha);

  %% Make it
  affinity       = diag(ones(1, n_clusters));
  affinity(1, :) = alpha;
  affinity(:, 1) = alpha;
  affinity(1, 1) = sum((alpha(2 : n_clusters) / (1 - alpha(1))) .^ 2);
endfunction