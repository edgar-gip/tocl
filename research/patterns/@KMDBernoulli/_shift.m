%% -*- mode: octave; -*-

%% k-Minority Detection

%% Bernoulli Component Extension

%% Author: Edgar Gonzalez

function [ new ] = _shift(this, data, idx)

  %% Call constructor
  new = KMDBernoulli(data(:, idx));
endfunction
