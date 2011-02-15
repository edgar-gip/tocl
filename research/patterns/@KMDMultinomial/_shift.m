%% -*- mode: octave; -*-

%% k-Minority Detection

%% Multinomial Component Extension

%% Author: Edgar Gonzalez

function [ new ] = _shift(this, data, idx)

  %% Call constructor
  new = KMDMultinomial(data(:, idx));
endfunction
