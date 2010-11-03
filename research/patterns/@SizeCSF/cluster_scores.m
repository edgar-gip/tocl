%% -*- mode: octave; -*-

%% Ensemble Weak One-Class Scoring
%% Size Cluster Scores

%% Author: Edgar Gonzalez

function [ scores ] = cluster_scores(this, data, expec)

  %% Find the size of each cluster
  scores = sum(expec, 2)';
endfunction
