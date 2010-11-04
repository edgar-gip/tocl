%% -*- mode: octave; -*-

%% Ensemble Weak One-Class Scoring
%% Size Cluster Scores

%% Author: Edgar Gonzalez

function [ scores ] = cluster_scores(this, data, expec)

  %% Check arguments
  if nargin() ~= 3
    usage("[ scores ] = @SizeCSF/cluster_scores(this, data, expec)");
  endif

  %% Find the size of each cluster
  scores = sum(expec, 2)';
endfunction
