%% -*- mode: octave; -*-

%% Dirichlet distribution clustering
%% Random data generation

%% Author: Edgar Gonzalez

function data = dirichlet_rnd(n_data, alphas)
  %% Draw from the gamma distribution
  data = gamma_rnd(ones(n_data, 1) * alphas, 1);

  %% Normalize
  data ./= sum(data, 2) * ones(1, length(alphas));
endfunction
