%% -*- mode: octave; -*-

%% k-Minority Detection

%% Bernoulli Component Extension

%% Author: Edgar Gonzalez

function [ new ] = _add(this, data, idx)

  %% Update unnormalized thetas
  new_n_data   = this.n_data   + length(idx);
  new_un_theta = this.un_theta + sum(data(:, idx) > 0, 2)';

  %% Construct
  new = KMDBernoulli(new_n_data, new_un_theta);
endfunction
