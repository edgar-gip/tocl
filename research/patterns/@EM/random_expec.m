%% -*- mode: octave; -*-

%% Expectation-Maximization clustering
%% Random expectation

%% Author: Edgar Gonzalez

function [ expec ] = random_expec(this, data, k)
  %% Plain random
  expec   = rand(k, n_data);
  expec ./= ones(k, 1) * sum(expec);
endfunction
