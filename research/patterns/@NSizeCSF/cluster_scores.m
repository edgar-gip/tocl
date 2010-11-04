%% -*- mode: octave; -*-

%% Ensemble Weak One-Class Scoring
%% Size Cluster Scores

%% Author: Edgar Gonzalez

function [ scores ] = cluster_scores(this, data, expec)

  %% Check arguments
  if nargin() ~= 3
    usage("[ scores ] = @NSizeCSF/cluster_scores(this, data, expec)");
  endif

  %% Number of clusters
  [ k, n_data ] = size(expec);

  %% Find the size of each cluster, and multiply by the number of clusters
  scores = k * sum(expec, 2)';
endfunction
