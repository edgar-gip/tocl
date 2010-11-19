%% -*- mode: octave; -*-

%% 1-D Gaussian distribution clustering
%% Expectation

%% Author: Edgar Gonzalez

function [ expec, log_like ] = expectation(this, data)

  %% Check arguments
  if nargin() ~= 2
    usage("[ expec, log_like ] = @Gaussian1DModel/expectation(this, data)");
  endif

  %% Number of data
  [ n_dims, n_data ] = size(data);

  %% Check dimensions
  if n_dims ~= 1
    error("The dimensionality must be one");
  endif

  %% Raw log-probability
  expec = this.log_alpha_var' * ones(1, n_data) ...
        - 0.5 * ((ones(this.k, 1) * data - ...
		  this.mean' * ones(1, n_data)) .^ 2) ./ ...
                 (this.var' * ones(1, n_data));

  %% Normalize
  max_expec = max(expec);
  sum_expec = max_expec .+ log(sum(exp(expec .- ones(this.k, 1) * max_expec)));
  expec     = exp(expec .- ones(this.k, 1) * sum_expec );

  %% Log-likelihood
  log_like = sum(sum_expec);
endfunction
