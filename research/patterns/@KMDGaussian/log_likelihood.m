%% -*- mode: octave; -*-

%% k-Minority Detection

%% Gaussian Component Conditional Log-Likelihood

%% Author: Edgar Gonzalez

function [ log_like ] = log_likelihood(this, data)

  %% Check arguments
  if nargin() ~= 2
    usage("[ log_like ] = @KMDGaussian/log_likelihood(this, data)");
  endif

  %% Size
  [ n_dims, n_data ] = size(data);

  %% Center the data
  cdata = data - this.mu * ones(1, n_data);

  %% Distance
  dist = sum(cdata .* (this.isigma * cdata), 1);

  %% Find it
  log_like = this.norm - 0.5 * dist;
endfunction
