%% -*- mode: octave; -*-

%% Gaussian distribution clustering
%% Expectation

%% Author: Edgar Gonzalez

function [ expec, log_like ] = expectation(this, data)

  %% Check arguments
  if nargin() ~= 2
    usage("[ expec, log_like ] = @GaussianModel/expectation(this, data)");
  endif

  %% Number of data
  [ n_feats, n_data ] = size(data);

  %% Distance
  expec = gaussian_log_expectation(this.alpha_pvar, this.mean, this.var, data);

  %% Normalize
  max_expec = max(expec);
  sum_expec = max_expec .+ log(sum(exp(expec .- ones(this.k, 1) * max_expec)));
  expec     = exp(expec .- ones(this.k, 1) * sum_expec );

  %% Log-likelihood
  log_like = sum(sum_expec);
endfunction
