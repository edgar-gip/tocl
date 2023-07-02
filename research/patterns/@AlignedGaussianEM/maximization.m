%% -*- mode: octave; -*-

%% Gaussian distribution EM clustering
%% Axis-aligned variance version
%% Maximization

%% Author: Edgar Gonzalez

function [ model ] = maximization(this, data, expec)

  %% Check arguments
  if nargin() ~= 3
    usage("[ model ] = @AlignedGaussianEM/maximization(this, data, expec)");
  endif

  %% Number of data and features
  [ n_dims, n_data ] = size(data);
  [ k     , n_data ] = size(expec);

  %% Cluster sizes
  cl_sizes = sum(expec, 2)'; % 1 * k

  %% Mean
  cl_mu = full(data * expec') ./ (ones(n_dims, 1) * cl_sizes); % n_dims * k

  %% Inverse covariances and normalization factors
  cl_isigma = zeros(n_dims, k); % n_dims * k
  cl_norm   = zeros(1, k);

  %% Find each
  for c = 1 : k
    %% Sum of squares
    sum2 = full(sum((data .* data) .* ...
                    (ones(n_dims, 1) * expec(c, :)), 2)); % n_dims * 1

    %% Variances
    sigma = sum2 / cl_sizes(c) - cl_mu(:, c) .* cl_mu(:, c);

    %% Check the minimum covariance is OK
    if ~isnan(this.min_covar) && min(sigma) < this.min_covar
      %% Unitary covariance
      cl_isigma(:, c) = ones(n_dims, 1);

      %% Normalization factor
      cl_norm(c) = -0.5 * n_dims * log(2 * pi);

    else
      %% Inverse
      cl_isigma(:, c) = 1 ./ sigma;

      %% Normalization factor
      %% \log \frac{1}{\sqrt{(2 \pi)^k \cdot | \Sigma |}}
      cl_norm(c) = -0.5 * (n_dims * log(2 * pi) + log(prod(sigma)));
    endif
  endfor

  %% Smoothen (and log) cl_sizes
  cl_sizes .+= this.alpha_prior;
  cl_sizes ./= n_data + k * this.alpha_prior;
  cl_sizes   = log(cl_sizes);

  %% Create the model
  model = AlignedGaussianEMModel(k, ...
                                 cl_sizes + cl_norm, ... % 1 * k
                                 cl_mu,              ... % n_dims * k
                                 cl_isigma);             % n_dims * k
endfunction
