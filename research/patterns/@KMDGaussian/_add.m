%% -*- mode: octave; -*-

%% k-Minority Detection

%% Gaussian Component Extension

%% Author: Edgar Gonzalez

function [ new ] = _add(this, data, idx)

  %% Update the size
  new_sum0 = this.sum0 + length(idx);

  %% Update the sum
  new_sum1 = this.sum1 + sum(data(:, idx), 2);

  %% Update the sum of products
  new_sum2 = this.sum2 + data(:, idx) * data(:, idx)';

  %% Construct
  new = KMDGaussian(this.n_dims, new_sum0, new_sum1, new_sum2);
endfunction
