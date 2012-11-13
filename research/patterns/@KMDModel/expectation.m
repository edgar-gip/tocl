%% -*- mode: octave; -*-

%% k-Minority Detection
%% Expectation

%% Author: Edgar Gonzalez

function [ expec, log_like ] = expectation(this, data)

  %% Check arguments
  if nargin() ~= 2
    usage("[ expec, log_like ] = @KMDModel/expectation(this, data)");
  endif

  %% Number of samples
  [ n_dims, n_samples ] = size(data);

  %% Number of components
  k = length(this.components);

  %% Only one?
  if k == 1
    %% Expectation and log-likelihood
    expec    = zeros(0, n_samples);
    log_like = sum(log_likelihood(this.components{1}, data));

  else
    %% Log-likelihood matrix
    log_like_matrix = this.log_alpha' * ones(1, n_samples);
    for c = 1 : k
      log_like_matrix(c, :) += log_likelihood(this.components{c}, data);
    endfor

    %% Normalize
    max_log_like      = max(log_like_matrix);
    log_like_matrix  -= ones(k, 1) * max_log_like;
    sum_log_like      = sum(exp(log_like_matrix));
    log_like_matrix ./= ones(k, 1) * sum_log_like;

    %% Expectation and log-likelihood
    expec    = log_like_matrix(2 : k, :);
    log_like = sum(max_log_like + log(sum_log_like));
  endif
endfunction
