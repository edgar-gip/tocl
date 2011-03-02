%% -*- mode: octave; -*-

%% Soft Bregman Bubble Clustering
%% Random expectation

%% Author: Edgar Gonzalez

function [ expec ] = random_expec(this, data, k)
  %% Number of data and features
  [ n_dims, n_data ] = size(data);

  %% Plain random
  expec   = rand(k, n_data);
  expec ./= ones(k, 1) * (sum(expec) + rand(1, n_data));
endfunction
