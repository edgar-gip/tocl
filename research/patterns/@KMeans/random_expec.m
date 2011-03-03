%% -*- mode: octave; -*-

%% k-Means clustering
%% Random expectation

%% Author: Edgar Gonzalez

function [ expec ] = random_expec(this, data, k)
  %% Number of data and features
  [ n_dims, n_data ] = size(data);

  %% Select seeds
  seeds = sort(randperm(n_data)(1 : k));

  %% Make the expectation
  expec = sparse(1 : k, seeds, ones(1, k), k, n_data);
endfunction
