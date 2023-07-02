%% -*- mode: octave; -*-

%% k-Minority Detection

%% Gaussian Component Constructor

%% Author: Edgar Gonzalez

function [ this ] = KMDGaussian(first, sum0, sum1, sum2)

  %% Check arguments
  if ~any(nargin() == [ 1, 4 ])
    usage("[ this ] = KMDGaussian(data | n_dims, sum0, sum1, sum2)");
  endif

  %% Data was given?
  if nargin() == 1
    %% Size
    [ n_dims, n_data ] = size(first);

    %% Size
    sum0 = size(first, 2);

    %% Sum
    sum1 = sum(first, 2);

    %% Sum of products
    sum2 = first * first';

  else
    %% Fetch
    n_dims = first;
  endif

  %% This object
  this = struct();

  %% Set fields
  this.n_dims = n_dims;
  this.sum0   = sum0;
  this.sum1   = sum1;
  this.sum2   = sum2;

  %% How many of them?
  if sum0 == 0
    %% None!
    this.mu     = [];
    this.isigma = [];
    this.norm   = nan;

  elseif sum0 == 1
    %% One
    this.mu     = this.sum1;
    this.isigma = eye(n_dims);
    this.norm   = -0.5 * n_dims * log(2 * pi);

  else
    %% More!

    %% Mean
    this.mu = sum1 / sum0;

    %% Covariance
    sigma =  sum0 / (sum0 - 1) * ...
            (sum2 /  sum0 - this.mu * this.mu');

    try
      %% Inverse
      this.isigma = inv(sigma);

      %% Normalization factor
      %% \log \frac{1}{\sqrt{(2 \pi)^k \cdot | \Sigma |}}
      this.norm = -0.5 * (n_dims * log(2 * pi) + log(det(sigma)));

    catch
      %% Singularity condition
      this.isigma = eye(n_dims);
      this.norm   = -0.5 * n_dims * log(2 * pi);
    end_try_catch
  endif

  %% Bless
  %% And add inheritance
  this = class(this, "KMDGaussian", ...
               KMDComponent());
endfunction
