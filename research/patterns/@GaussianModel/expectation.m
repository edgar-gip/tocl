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
  [ n_dims, n_data ] = size(data);

  %% Raw probability
  %% Start with the a priori probabilities
  expec = this.alpha_pvar' * ones(1, n_data);

  %% For each cluster
  for c = 1 : this.k
    %% Scale data
    s_data = data ./ (this.stdev(:, c) * ones(1, n_data));

    %% Distances
    expec(c, :) -= sq_euclidean_distance2(this.mean_stdev(:, c), s_data);
  endfor

  %% Normalize
  max_expec = max(expec);
  sum_expec = max_expec .+ log(sum(exp(expec .- ones(this.k, 1) * max_expec)));
  expec     = exp(expec .- ones(this.k, 1) * sum_expec );

  %% Log-likelihood
  log_like = sum(sum_expec);
endfunction
