%% -*- mode: octave; -*-

%% k-Minority Detection

%% Bernoulli Component Conditional Log-Likelihood

%% Author: Edgar Gonzalez

function [ log_like ] = log_likelihood(this, data)

  %% Check arguments
  if nargin() ~= 2
    usage("[ log_like ] = @KMDBernoulli/log_likelihood(this, data)");
  endif

  %% Find it
  log_like = this.log_ctheta + (this.clog_theta * (data > 0));
endfunction
