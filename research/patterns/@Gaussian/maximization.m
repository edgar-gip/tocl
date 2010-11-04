%% -*- mode: octave; -*-

%% Gaussian distribution clustering
%% Maximization

%% Author: Edgar Gonzalez

function [ model ] = maximization(this, data, expec)

  %% Check arguments
  if nargin() ~= 3
    usage("[ model ] = @Gaussian/maximization(this, data, expec)");
  endif

  %% Number of data and features
  [ n_dims, n_data ] = size(data);
  [ k     , n_data ] = size(expec);

  %% Cluster sizes
  cl_sizes  = sum(expec, 2); % k * 1

  %% Sum and sum_sq
  cl_sum   = full( data          * expec');
  cl_sumsq = full((data .* data) * expec');

  %% Mean and variance
  cl_mean = cl_sum   ./ (ones(n_dims, 1) * cl_sizes);
  cl_var  = cl_sumsq ./ (ones(n_dims, 1) * cl_sizes) - cl_mean .* cl_mean;

  %% Sqrt of product of variances
  cl_pvar = sqrt(prod(cl_var));

  %% Smoothen (and log) cl_sizes
  cl_sizes .+= this.alpha_prior;
  cl_sizes ./= n_data + k * this.alpha_prior;
  cl_sizes   = log(cl_sizes);

  %% Create the model
  model = GaussianModel(k, ...
			cl_sizes - log(cl_pvar), ... % k * 1
			cl_mean, ...                 % k * n_dims
			cl_var);                     % k * n_dims
endfunction
