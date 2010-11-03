%% -*- mode: octave; -*-

%% Bernoulli distribution clustering
%% Maximization

%% Author: Edgar Gonzalez

function model = maximization(this, data, expec)

  %% Number of data and features
  [ n_dims, n_data ] = size(data);
  [ k     , n_data ] = size(expec);

  %% Cluster sizes and active features
  cl_sizes  = sum(expec, 2);       % k * 1
  cl_active = full(data * expec'); % n_dims * k

  %% Smoothen cl_active
  cl_active .+= this.theta_prior;
  cl_active ./= ones(n_dims, 1) * (cl_sizes .+ 2 * this.theta_prior)';

  %% Find cl_theta and cl_ctheta
  pos_log   = log(cl_active);      % n_dims * k
  neg_log   = log(1 .- cl_active); % n_dims * k
  cl_theta  = pos_log .- neg_log;  % n_dims * k
  cl_ctheta = sum(neg_log)';       %      k * 1

  %% Smoothen (and log) cl_sizes
  cl_sizes .+= this.alpha_prior;
  cl_sizes ./= n_data + k * this.alpha_prior;
  cl_sizes   = log(cl_sizes);

  %% Create the model
  model = BernoulliModel(k, ...
			 cl_sizes, ...              % k * 1
			 cl_sizes .+ cl_ctheta, ... % k * 1
			 cl_theta');                % k * n_dims
endfunction
