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
      noise_data(:, 1 : cmd_opts.noise_size) = ...
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

  %% Noise range
  min_noise = min(data(:, 1 : cmd_opts.noise_size)')';
  max_noise = max(data(:, 1 : cmd_opts.noise_size)')';

  %% Previous signal means
  sqe = SqEuclideanDistance();
  prev_signal_means = [];

  %% Signal
  cl   = 2;
  base = cmd_opts.noise_size;
  for cur_size = cmd_opts.signal_size
    %% Try it!
    tries = 0;
    ok    = false();
    while tries < 50 && ~ok
      %% Generate an effective signal mean
      eff_signal_mean = ...
	  eff_noise_mean + gen_gaussian(cmd_opts.dimensions, 1, ...
					0, cmd_opts.signal_shift);

      %% Not outside
      ok = all(min_noise <= eff_signal_mean && eff_signal_mean <= max_noise);

      %% Distance from previous
      if ok && ~isempty(prev_signal_means)
	dists = apply(sqe, prev_signal_means, eff_signal_mean);
	ok    = sqrt(min(dists)) >= cmd_opts.signal_space;
      endif

      %% One more try
      tries += 1;
    endwhile

    %% OK?
    if ok
      %% Add it
      prev_signal_means = [ prev_signal_means, eff_signal_mean ];
    else
      %% Error
      error("Could not generate means far enough");
    endif

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
