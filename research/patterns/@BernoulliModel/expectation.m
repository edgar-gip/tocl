%% -*- mode: octave; -*-

%% Bernoulli distribution clustering
%% Expectation

%% Author: Edgar Gonzalez

function [ expec, log_like ] = expectation(this, data)

  %% Check arguments
  if nargin() ~= 2
    usage("[ expec, log_like ] = @BernoulliModel/expectation(this, data)");
  endif

  %% Number of data
  [ n_dims, n_data ] = size(data);

  %% Find the expectation
  expec = this.alpha_ctheta * ones(1, n_data) .+ ...
          this.theta        * (data > 0);

  %% Normalize
  max_expec = max(expec);
  sum_expec = max_expec .+ log(sum(exp(expec .- ones(this.k, 1) * max_expec)));
  expec     = exp(expec .- ones(this.k, 1) * sum_expec );

  %% Log-likelihood
  log_like = sum(sum_expec);
endfunction
