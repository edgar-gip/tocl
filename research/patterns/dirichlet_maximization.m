%% -*- mode: octave; -*-

%% Dirichlet distribution clustering
%% Maximization

%% Author: Edgar Gonzalez

function model = dirichlet_maximization(log_data, blocks, expec)
  %% Number of data and features
  [ n_dims, n_data ] = size(log_data);
  [ k     , n_data ] = size(expec); 

  %% Cluster sizes
  cl_sizes = sum(expec, 2); % k * 1

  %% Observed sum of logs
  cl_obs   = full(log_data * expec');     % n_dims * k
  cl_obs ./= ones(n_dims, 1) * cl_sizes';

  %% Fit the thetas for each block and cluster
  [ cl_theta, cl_z ] = dirichlet_estimation(blocks, cl_obs);

  %% Smoothen cl_sizes
  cl_sizes .+= 1;
  cl_sizes ./= n_data + k;

  %% Create the model
  model          = struct();
  model.k        = k;
  model.blocks   = blocks;
  model.alpha    = log(cl_sizes);                   % k * 1
  model.z        = cl_z;                            % k * n_blocks
  model.alpha_z  = model.alpha - sum(log(cl_z), 2); % k * 1
  model.theta_m1 = cl_theta - 1;                    % k * n_dims
endfunction
