%% -*- mode: octave; -*-

%% Dirichlet distribution clustering
%% Maximization

%% Author: Edgar Gonzalez

function [ model ] = maximization(this, log_data, blocks, expec)

  %% Check arguments
  if nargin() ~= 4
    usage("[ model ] = @Dirichlet/maximization(this, log_data, blocks, expec)");
  endif

  %% Number of data and features
  [ n_dims, n_data ] = size(log_data);
  [ k     , n_data ] = size(expec);

  %% Cluster sizes
  cl_sizes = sum(expec, 2); % k * 1

  %% Observed sum of logs
  cl_obs   = full(log_data * expec');     % n_dims * k
  cl_obs ./= ones(n_dims, 1) * cl_sizes';

  %% Fit the thetas for each block and cluster
  [ cl_theta, cl_log_z ] = dirichlet_estimation(blocks, cl_obs);

  %% Smoothen (and log) cl_sizes
  cl_sizes .+= 1;
  cl_sizes ./= n_data + k;
  cl_sizes   = log(cl_sizes);

  %% Create the model
  model = DirichletModel(k,
			 blocks,
			 cl_sizes,                    % k * 1
			 cl_log_z,                    % k * n_blocks
			 cl_sizes - sum(cl_log_z, 2), % k * 1
			 cl_theta - 1);               % k * n_dims
endfunction
