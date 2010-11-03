%% -*- mode: octave; -*-

%% Bernoulli distribution clustering
%% Expectation

%% Author: Edgar Gonzalez

function [ expec, log_like ] = expectation(this, data)
  %% Number of data
  n_data = size(data, 2);

  %% Find the expectation
  expec = this.alpha_ctheta * ones(1, n_data) .+ ...
          this.theta        * data;

  %% Normalize
  max_expec = max(expec);
  sum_expec = max_expec .+ log(sum(exp(expec .- ones(this.k, 1) * max_expec)));
  expec     = exp(expec .- ones(this.k, 1) * sum_expec );

  %% Log-likelihood
  log_like = sum(sum_expec);
endfunction
