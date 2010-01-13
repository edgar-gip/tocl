%% Bernoulli distribution clustering
%% Maximization

%% Author: Edgar Gonzalez

function model = bernoulli_maximization(data, expec)
  %% Number of data and features
  [ n_dims, n_data ] = size(data);
  [ k     , n_data ] = size(expec); 

  %% Cluster sizes and active features
  cl_sizes  = sum(expec, 2);       % k * 1
  cl_active = full(data * expec'); % n_dims * k

  %% Smoothen cl_active
  cl_active .+= 1;
  cl_active ./= ones(n_dims, 1) * (cl_sizes .+ 2)';

  %% Find cl_theta and cl_ctheta
  pos_log   = log(cl_active);      % n_dims * k
  neg_log   = log(1 .- cl_active); % n_dims * k
  cl_theta  = pos_log .- neg_log;  % n_dims * k
  cl_ctheta = sum(neg_log)';       %      k * 1

  %% Smoothen cl_sizes
  cl_sizes .+= 1;
  cl_sizes ./= n_data + k;

  %% Create the model
  model              = struct();
  model.k            = k;
  model.alpha        = log(cl_sizes);            % k * 1
  model.alpha_ctheta = model.alpha .+ cl_ctheta; % k * 1
  model.theta        = cl_theta';                % k * n_dims

%% Local Variables:
%% mode:octave
%% End:
