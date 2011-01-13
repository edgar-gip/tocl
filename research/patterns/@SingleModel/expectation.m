%% -*- mode: octave; -*-

%% Single cluster
%% Expectation

%% Author: Edgar Gonzalez

function [ expec, log_like ] = expectation(this, data)

  %% Check arguments
  if nargin() ~= 2
    usage("[ expec, log_like ] = @SingleModel/expectation(this, data)");
  endif

  %% Number of samples
  [ n_dims, n_samples ] = size(data);

  %% Expectation
  expec = ones(1, n_samples);

  %% Log-likelihood is not considered here
  log_like = nan;
endfunction
