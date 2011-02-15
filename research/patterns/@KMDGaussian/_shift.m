%% -*- mode: octave; -*-

%% k-Minority Detection

%% Gaussian Component Extension

%% Author: Edgar Gonzalez

function [ new ] = _shift(this, data, idx)

  %% Call constructor
  new = KMDGaussian(data(:, idx));
endfunction
