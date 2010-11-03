%% -*- mode: octave; -*-

%% Ensemble Weak One-Class Scoring
%% Size Cluster Scores

%% Author: Edgar Gonzalez

function [ scores ] = cluster_scores(this, data, expec)

  %% Number of clusters
  [ k, n_data ] = size(expec);

  %% Find the size of each cluster, and multiply by the number of clusters
  scores = k * sum(expec, 2)';
endfunction
