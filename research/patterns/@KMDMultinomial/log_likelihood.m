%% -*- mode: octave; -*-

%% k-Minority Detection

%% Multinomial Component Conditional Log-Likelihood

%% Author: Edgar Gonzalez

function [ log_like ] = log_likelihood(this, data)

  %% Check arguments
  if nargin() ~= 2
    usage("[ log_like ] = @KMDMultinomial/log_likelihood(this, data)");
  endif

  %% Find it
  %% The factorial terms are ignored, given that they are the same
  %% across all components, and can be factored out
  log_like = this.log_theta * data;
endfunction
