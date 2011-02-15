%% -*- mode: octave; -*-

%% k-Minority Detection

%% Multinomial Component Reduction

%% Author: Edgar Gonzalez

function [ new ] = _remove(this, data, idx)

  %% Update unnormalized thetas
  new_un_theta = this.un_theta - sum(data(:, idx), 2)';

  %% Construct
  new = KMDMultinomial(this.n_dims, new_un_theta);
endfunction
