%% -*- mode: octave; -*-

%% Generate some nice data, in the style of Ando

%% Author: Edgar Gonzàlez i Pellicer

%% Generate the data
function [ data, truth, desc ] = ando_data(generator, dims, extra)
  switch generator
    case "unibg"
      [ data, truth, desc ] = data_unibg(dims, extra);
    case "unibg_ss"
      [ data, truth, desc ] = data_unibg_ss(dims, extra);
    case "unibg_rs"
      [ data, truth, desc ] = data_unibg_rs(dims, extra);
    case "gaussbg"
      [ data, truth, desc ] = data_gaussbg(dims, extra);
    case "bernoulli"
      [ data, truth, desc ] = data_bernoulli(dims, extra);
    case "special1"
      [ data, truth, desc ] = data_special1(dims, extra);
    otherwise
      error(sprintf("Wrong data generator '%s'", generator));
  endswitch
endfunction


%%%%%%%%%%%%%%%%%%%%%%%
%% Private functions %%
%%%%%%%%%%%%%%%%%%%%%%%

%% Distributions
%% enum P_BERNOULLI P_GAUSSIAN P_SPHERICAL P_UNIFORM

%% Uniform background
function [ data, truth, desc ] = data_unibg(dims, extra)
  %% Generate it
  desc = struct("dimensions", dims,

		"noise_dist", P_UNIFORM,
		"noise_size", 1000 * 2 ^ dims,
		"noise_mean", 0.0,
		"noise_var",  2.0,

		"signal_dist",  P_GAUSSIAN,
		"signal_size",  [ 100, 150, 150, 200 ],
		"signal_var",   0.125,
		"signal_mean",  0.0,
		"signal_shift", 0.75,
		"signal_space", 0.75);
  [ data, truth ] = gen_data(desc);
endfunction

%% Uniform background (same size)
function [ data, truth, desc ] = data_unibg_ss(dims, extra)
  %% Parse extra arguments
  if length(extra) ~= 3
    error("'unibg_ss' generator expects 3 extra arguments");
  endif
  noise_scale  = str2double(extra{1});
  signal_scale = str2double(extra{2});
  signal_var   = str2double(extra{3});

  %% Noise size
  noise_size = 0;
  while noise_size < 1000
    noise_size = round(noise_scale * (5400 + 600 * randn()));
  endwhile

  %% Signal sizes
  signal_groups    = floor(3 + 5 * rand());
  mean_signal_size = 800 / signal_groups;
  signal_sizes     = zeros(1, signal_groups);
  while ~all(signal_sizes > 50)
    signal_sizes = ...
	round(signal_scale * (mean_signal_size + 50 * randn(1, signal_groups)));
  endwhile

  %% Generate it
  desc = struct("dimensions", dims,

		"noise_dist", P_UNIFORM,
		"noise_size", noise_size,
		"noise_mean", 0.0,
		"noise_var",  2.0,

		"signal_dist",  P_GAUSSIAN,
		"signal_size",  signal_sizes,
		"signal_var",   signal_var * 0.125,
		"signal_mean",  0.0,
		"signal_shift", 0.75,
		"signal_space", 0.75);
  [ data, truth ] = gen_data(desc);
endfunction

%% Uniform background (random sizes)
function [ data, truth, desc ] = data_unibg_rs(dims, extra)
  %% Sizes
  groups      = floor(   1 +   5 * rand())
  signal_size = round( 150 +  50 * randn(1, groups))
  noise_size  = round(1500 + 500 * randn())

  %% Generate
  desc = struct("dimensions", dims,

		"noise_dist", P_UNIFORM,
		"noise_size", noise_size,
		"noise_mean", 0.0,
		"noise_var",  2.0,

		"signal_dist",  P_GAUSSIAN,
		"signal_size",  signal_size,
		"signal_var",   0.125,
		"signal_mean",  0.0,
		"signal_shift", 0.75,
		"signal_space", 0.75);
  [ data, truth ] = gen_data(desc);
endfunction

%% Gaussian background
function [ data, truth, desc ] = data_gaussbg(dims, extra)
  %% Generate it
  desc = struct("dimensions", dims,

 		"noise_dist", P_SPHERICAL,
		"noise_size", 1000 * 2 ^ dims,
		"noise_mean", 0.0,
		"noise_var",  2.0,

		"signal_dist",  P_GAUSSIAN,
		"signal_size",  [ 100, 150, 150, 200 ],
		"signal_var",   0.125,
		"signal_mean",  0.0,
		"signal_shift", 0.75,
		"signal_space", 0.75);
  [ data, truth ] = gen_data(desc);
endfunction

%% Bernoullis
function [ data, truth, desc ] = data_bernoulli(dims, extra)
  %% Params
  bg_size      = 4000;
  bg_theta_max = 0.1;
  sizes        = [ 100, 150, 150, 200 ];
  thetas       = [ 0.8, 0.7, 0.6, 0.5 ];
  active_frak  = 0.1;

  %% Active dims
  n_active_dims = round(dims * active_frak);

  %% Bg theta
  bg_theta = bg_theta_max * rand(dims, 1);

  %% Background
  data  = sparse(rand(dims, bg_size) < bg_theta * ones(1, bg_size));
  truth = ones(1, bg_size);

  %% Signals
  for c = 1 : length(sizes)
    %% Generate the subset of active dims
    active_dims = randperm(dims)(1 : n_active_dims);

    %% Signal theta
    signal_theta = bg_theta;
    signal_theta(active_dims, 1) = thetas(c);

    %% Data
    signal_data = ...
	sparse(rand(dims, sizes(c)) < signal_theta * ones(1, sizes(c)));

    %% Join
    data  = [ data,  signal_data ];
    truth = [ truth, (c + 1) * ones(1, sizes(c)) ];
  endfor

  %% Make it sparse
  data = sparse(data);

  %% Shuffle
  shuffler = randperm(length(truth));
  data  = data (:, shuffler);
  truth = truth(shuffler);

  %% No description
  desc = struct();
endfunction

%% Special 1
function [ data, truth, desc ] = data_special1(dims, extra)
  %% Number of dimensions?
  if dims == 2
    %% Triangle
    means = [ 0.000,  1.000 ; ...
	      0.866, -0.500 ; ...
	     -0.866, -0.500 ]';
    sizes = [ 100, 150, 200 ];

  elseif dims == 3
    %% Tetrahedron
    %% From http://www.cs.umbc.edu/~squire/reference/polyhedra.shtml
    means = [ 0.000,  0.000,  1.000 ; ...
	      0.943,  0.000, -0.333 ; ...
	     -0.471,  0.816, -0.333 ; ...
	     -0.471, -0.816, -0.333 ]';
    sizes = [ 100, 150, 150, 200 ];

  else
    error("special1 generator suitable only for 2,3-dimensional data");
  endif

  %% Params
  bg_size = 1000;
  sx_var  = 0.0125;

  %% Background
  data  = 8.0 * (rand(dims, bg_size) - 0.5);
  truth = ones(1, bg_size);

  %% Signals
  for c = 1 : length(sizes)
    data  = [ data, 2.0 * means(:, c) * ones(1, sizes(c)) + ...
	            sx_var * eye(dims) * randn(dims, sizes(c)) ];
    truth = [ truth, (c + 1) * ones(1, sizes(c)) ];
  endfor

  %% Shuffle
  shuffler = randperm(length(truth));
  data  = data (:, shuffler);
  truth = truth(shuffler);

  %% No description
  desc = struct();
endfunction
