%% -*- mode: octave; -*-

%% Multinomial distribution clustering
%% Maximization

%% Author: Edgar Gonzalez

function [ model ] = maximization(this, data, expec)

  %% Check arguments
  if nargin() ~= 3
    usage("[ model ] = @Multinomial/maximization(this, data, expec)");
  endif

  %% Number of data and features
  [ n_dims, n_data ] = size(data);
  [ k     , n_data ] = size(expec);

  %% Cluster sizes and active features
  cl_sizes  = sum(expec, 2);       % k * 1
  cl_active = full(data * expec'); % n_dims * k
  cl_words  = sum(cl_active, 1)';  % k * 1

  %% Smoothen (and log) cl_active
  cl_active .+= this.theta_prior;
  cl_active ./= ones(n_dims, 1) * (cl_words .+ n_dims * this.theta_prior)';
  cl_active   = log(cl_active);

  %% Smoothen (and log) cl_sizes
  cl_sizes .+= this.alpha_prior;
  cl_sizes ./= n_data + k * this.alpha_prior;
  cl_sizes   = log(cl_sizes);

  %% Create the model
  model = MultinomialModel(k, ...
                           cl_sizes, ... % k * 1
                           cl_active');  % k * n_dims
endfunction
