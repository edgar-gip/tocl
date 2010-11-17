%% -*- mode: octave; -*-

%% Generate some nice data

%% Author: Edgar Gonzàlez i Pellicer

%% Generate the data
function [ data, truth ] = gen_data(cmd_opts)
  %% Total size
  total_size = cmd_opts.noise_size + sum(cmd_opts.signal_size);

  %% Now, generate
  data  = zeros(cmd_opts.dimensions, total_size);
  truth = ones (1,                   total_size);

  %% Effective noise mean
  eff_noise_mean = gen_gaussian(cmd_opts.dimensions, 1, ...
				0, cmd_opts.noise_mean);

  %% Noise
  switch cmd_opts.noise_dist
    case P_BERNOULLI
      data(:, 1 : cmd_opts.noise_size) = ...
	  gen_bernoulli(cmd_opts.dimensions, cmd_opts.noise_size, ...
			cmd_opts.noise_mean);
    case P_GAUSSIAN
      data(:, 1 : cmd_opts.noise_size) = ...
	  gen_gaussian(cmd_opts.dimensions, cmd_opts.noise_size, ...
		       eff_noise_mean, cmd_opts.noise_var);
    case P_SPHERICAL
      data(:, 1 : cmd_opts.noise_size) = ...
	  gen_spherical(cmd_opts.dimensions, cmd_opts.noise_size, ...
			eff_noise_mean, cmd_opts.noise_var);
    case P_UNIFORM
      data(:, 1 : cmd_opts.noise_size) = ...
	  gen_uniform(cmd_opts.dimensions, cmd_opts.noise_size, ...
		      eff_noise_mean, cmd_opts.noise_var);
  endswitch

  %% Signal
  cl   = 2;
  base = cmd_opts.noise_size;
  for cur_size = cmd_opts.signal_size
    %% Effective signal mean
    eff_signal_mean = ...
	eff_noise_mean + gen_gaussian(cmd_opts.dimensions, 1, ...
				      0, cmd_opts.signal_shift);

    %% Generate each one
    switch cmd_opts.signal_dist
      case P_BERNOULLI
	data(:, base : base + cur_size - 1) = ...
	    gen_bernoulli(cmd_opts.dimensions, cur_size, ...
			  cmd_opts.noise_mean + rand() * cmd_opts.signal_shift);
      case P_GAUSSIAN
	data(:, base : base + cur_size - 1) = ...
	    gen_gaussian(cmd_opts.dimensions, cur_size, ...
			 eff_signal_mean, cmd_opts.signal_var);
      case P_SPHERICAL
	data(:, base : base + cur_size - 1) = ...
	    gen_spherical(cmd_opts.dimensions, cur_size, ...
			  eff_signal_mean, cmd_opts.signal_var);
      case P_UNIFORM
	data(:, base : base + cur_size - 1) = ...
	    gen_uniform(cmd_opts.dimensions, cur_size, ...
			eff_signal_mean, cmd_opts.signal_var);
    endswitch

    %% Truth
    truth(base : base + cur_size - 1) = cl;

    %% Next
    base += cur_size;
    cl   += 1;
  endfor

  %% Shuffle
  shuffler = randperm(total_size);
  data  = data (:, shuffler);
  truth = truth(shuffler);
endfunction


%%%%%%%%%%%%%%%%%%%%%%%
%% Private Functions %%
%%%%%%%%%%%%%%%%%%%%%%%

%% Distributions
enum P_BERNOULLI P_GAUSSIAN P_SPHERICAL P_UNIFORM

%% Generate uniform
function [ data ] = gen_uniform(dims, size, mean, var)
  %% Data
  data = mean * ones(1, size) + 2 * var * (rand(dims, size) - 0.5);
endfunction

%% Generate bernoulli
function [ data ] = gen_bernoulli(dims, size, mean)
  %% Data
  data = rand(dims, size) < mean;
endfunction

%% Generate gaussian
function [ data ] = gen_gaussian(dims, size, mean, var)
  %% Variance projection
  project   = rand(dims, dims) - 0.5;
  project ./= ones(dims, 1) * sqrt(sum(project .* project));
  variance  = project * diag(var * (1 + rand(dims, 1)) / 2, 0);

  %% Data
  data = mean * ones(1, size) + variance * randn(dims, size);
endfunction

%% Generate spherical
function [ data ] = gen_spherical(dims, size, mean, var)
  %% Variance projection
  variance = var * eye(dims);

  %% Data
  data = mean * ones(1, size) + variance * randn(dims, size);
endfunction
