%% -*- mode: octave; -*-

%% k-Means clustering
%% Expectation

%% Author: Edgar Gonzalez

function [ expec, log_like ] = expectation(this, data)

  %% Check arguments
  if nargin() ~= 2
    usage("[ expec, log_like ] = @KMeansModel/expectation(this, data)");
  endif

  %% Number of samples
  [ n_dims, n_samples ] = size(data);

  %% Find the divergence matrix
  divs = apply(this.divergence, this.centroids, data);

  %% Select the closest cluster
  [ min_divs, min_indices ] = min(divs);

  %% Expectation
  expec = sparse(min_indices, 1 : n_samples, ones(1, n_samples), ...
                 this.k, n_samples);

  %% Log-likelihood is not considered here
  log_like = nan;
endfunction
