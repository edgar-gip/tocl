%% -*- mode: octave; -*-

%% k-Minority Detection

%% Multinomial Component Conditional Log-Likelihood

%% Author: Edgar Gonzalez

function [ log_like ] = log_likelihood(this, data)

  %% Check arguments
  if nargin() ~= 2
    usage("[ log_like ] = @KMDMultinomial/log_likelihood(this, data)");
  endif

  %% Find the factorial normalization
  fnorm = factorial_normalization(data);

  %% Find it
  log_like = fnorm .* (this.log_theta * data);
endfunction
