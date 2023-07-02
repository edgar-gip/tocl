%% -*- mode: octave; -*-

%% Gaussian distribution EM clustering
%% Axis-aligned variance version
%% Expectation

%% Author: Edgar Gonzalez

function [ expec, log_like ] = expectation(this, data)

  %% Check arguments
  if nargin() ~= 2
    usage(cstrcat("[ expec, log_like ] =", ...
                  " @AlignedGaussianEMModel/expectation(this, data)"));
  endif

  %% Number of data
  [ n_dims, n_data ] = size(data);

  %% Raw probability
  %% Start with the a priori probabilities and normalization terms
  expec = this.alpha_norm' * ones(1, n_data);

  %% For each cluster
  for c = 1 : this.k
    %% Center the data
    cdata = data - this.mu(:, c) * ones(1, n_data);

    %% Distance
    dist = sum(cdata .* (diag(this.isigma(:, c)) * cdata), 1);

    %% Find it
    expec(c, :) -= 0.5 * dist;
  endfor

  %% Normalize
  max_expec = max(expec);
  sum_expec = max_expec .+ log(sum(exp(expec .- ones(this.k, 1) * max_expec)));
  expec     = exp(expec .- ones(this.k, 1) * sum_expec);

  %% Log-likelihood
  log_like = sum(sum_expec);
endfunction
