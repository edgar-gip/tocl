%% -*- mode: octave; -*-

%% 1D Gaussian distribution clustering
%% Maximization

%% Author: Edgar Gonzalez

function [ model ] = maximization(this, data, expec)

  %% Check arguments
  if nargin() ~= 3
    usage("[ model ] = @Gaussian1D/maximization(this, data, expec)");
  endif

  %% Number of data and features
  [ n_dims, n_data ] = size(data);
  [ k     , n_data ] = size(expec);

  %% Check dimensions
  if n_dims ~= 1
    error("The dimensionality must be one");
  endif

  %% Cluster sizes
  cl_sizes = sum(expec, 2); % k * 1

  %% Sum and sum_sq
  cl_sum   = full(expec *  data');
  cl_sumsq = full(expec * (data .* data)');

  %% Mean and variance
  cl_mean = cl_sum   ./ cl_sizes;
  cl_var  = cl_sumsq ./ cl_sizes - cl_mean .* cl_mean;

  %% Smoothen (and log) cl_sizes
  cl_sizes .+= this.alpha_prior;
  cl_sizes ./= n_data + k * this.alpha_prior;
  cl_sizes   = log(cl_sizes);

  %% Create the model
  model = Gaussian1DModel(k, ...
			  cl_sizes - 0.5 * log(cl_var), ... % k * 1
			  cl_mean, ...                      % k * 1
			  cl_var);                          % k * 1
endfunction
