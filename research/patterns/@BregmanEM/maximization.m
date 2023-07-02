%% -*- mode: octave; -*-

%% Bregman Divergence EM-like clustering
%% Maximization

%% Author: Edgar Gonzalez

function [ model ] = maximization(this, data, expec)

  %% Check arguments
  if nargin() ~= 3
    usage("[ model ] = @BregmanEM/maximization(this, data, expec)");
  endif

  %% Number of data and features
  [ n_dims, n_data ] = size(data);
  [ k     , n_data ] = size(expec);

  %% Cluster sizes
  cl_sizes = sum(expec, 2)'; % 1 * k

  %% Mean
  cl_mu = full(data * expec') ./ (ones(n_dims, 1) * cl_sizes); % n_dims * k

  %% Smoothen (and log) cl_sizes
  cl_sizes .+= this.alpha_prior;
  cl_sizes ./= n_data + k * this.alpha_prior;
  cl_sizes   = log(cl_sizes);

  %% Create the model
  model = BregmanEMModel(this.divergence, ...
                         this.beta, ...
                         k, ...
                         cl_sizes, ... % 1 * k
                         cl_mu);       % n_dims * k
endfunction
