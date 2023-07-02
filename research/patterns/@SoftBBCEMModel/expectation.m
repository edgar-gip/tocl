%% -*- mode: octave; -*-

%% Soft Bregman Bubble Clustering
%% Expectation

%% Author: Edgar Gonzalez

function [ expec, log_like ] = expectation(this, data)

  %% Check arguments
  if nargin() ~= 2
    usage("[ expec, log_like ] = @SoftBBCEMModel/expectation(this, data)");
  endif

  %% Size
  [ n_dims, n_data ] = size(data);

  %% Find the raw expectation
  expec = this.alpha' * ones(1, n_data) - ...
          this.beta * apply(this.divergence, this.centroids, data);

  %% Normalize
  max_expec = max(max(expec, [], 1), this.bg_alpha);
  sum_expec = max_expec .+ ...
              log(sum(exp(expec .- ones(this.k, 1) * max_expec)) + ...
                  exp(this.bg_alpha - max_expec));
  expec     = exp(expec .- ones(this.k, 1) * sum_expec );

  %% Log-likelihood
  log_like = sum(sum_expec);
endfunction
