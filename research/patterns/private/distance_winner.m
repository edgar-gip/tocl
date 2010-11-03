%% -*- mode: octave; -*-

%% Support Vector Machines (Revisited)
%% From distance to a sparse matrix with the winners
%% Main procedure

%% Author: Edgar Gonzalez

function [ winner ] = distance_winner(distances)

  %% A two-class problem?
  [ n_classes, n_data ] = size(distances);
  if n_classes == 1
    %% Fight against its own negation
    distances = [ distances ; -distances ];
    n_classes = 2;
  endif

  %% Find the maxima and its indices
  [ maxima, indices ] = max(distances);

  %% Winners
  winner = sparse(indices, 1 : n_data, ones(1, n_data), n_classes, n_data);
endfunction
