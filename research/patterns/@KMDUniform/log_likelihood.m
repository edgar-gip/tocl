%% -*- mode: octave; -*-

%% k-Minority Detection

%% Uniform Component Conditional Log-Likelihood

%% Author: Edgar Gonzalez

function [ log_like ] = log_likelihood(this, data)

  %% Check arguments
  if nargin() ~= 2
    usage("[ log_like ] = @KMDUniform/log_likelihood(this, data)");
  endif

  %% Size
  [ n_dims, n_data ] = size(data);

  %% Find it
  log_like = this.log_p * ones(1, n_data);
endfunction
