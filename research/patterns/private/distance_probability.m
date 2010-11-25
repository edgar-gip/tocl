%% -*- mode: octave; -*-

%% Support Vector Machines (Revisited)
%% From distance to the hyperplane to a probability
%% Main procedure

%% Author: Edgar Gonzalez

function [ probability ] = distance_probability(alpha, distances)

  %% A two-class problem?
  n_classes = size(distances, 1);
  if n_classes == 1
    %% Fight against its own negation
    distances = [ distances ; -distances ];
    n_classes = 2;
  endif

  %% Normalize
  max_dist    = max(distances);
  distances .-= ones(n_classes, 1) * max_dist;

  %% Convert to exponential
  probability = exp(alpha * distances);

  %% Find the normalization terms
  normalization = sum(probability, 1);

  %% Divide
  probability ./= ones(n_classes, 1) * normalization;
endfunction
