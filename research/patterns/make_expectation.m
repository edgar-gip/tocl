%% -*- mode: octave; -*-

%% Make an expectation

%% Author: Edgar Gonzalez

function [ expec ] = make_expectation(classes)
  %% Size
  n_data = length(classes);

  %% Convert
  expec = sparse(classes, 1 : n_data, ones(1, n_data));
endfunction
