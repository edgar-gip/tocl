%% -*- mode: octave; -*-

%% Generate the data from
%% Shin Ando
%% "Clustering Needles in a Haystack: An Information Theoretic
%%  Analysis of Minority And Outlier Detection"
%% 7th IEEE Conference on Data Mining, 2007

%% Author: Edgar Gonzàlez i Pellicer


%% Octopus
pkg load octopus;


%%%%%%%%%%%%%
%% Helpers %%
%%%%%%%%%%%%%

%% Fields
function [ joint ] = fields(s)
  %% Field names
  names = strcat(fieldnames(s), ",");
  joint = strcat(names{:});
  joint = substr(joint, 1, length(joint) - 1);
endfunction


%%%%%%%%%%%%%%%%%%%%%
%% Data Generation %%
%%%%%%%%%%%%%%%%%%%%%

%% Distributions
enum P_BERNOULLI P_GAUSSIAN P_SPHERICAL P_UNIFORM

%% Uniform background
function [ data, truth ] = data_unibg(dims, extra)
  %% Generate it
  [ data, truth ] = gen_data(struct("dimensions", dims,

				    "noise_dist", P_UNIFORM,
				    "noise_size", 1000 * 2 ^ dims,
				    "noise_mean", 0.0,
				    "noise_var",  2.0,

				    "signal_dist",  P_GAUSSIAN,
				    "signal_size",  [ 100, 150, 150, 200 ],
				    "signal_var",   0.125,
				    "signal_mean",  0.0,
				    "signal_shift", 0.75,
				    "signal_space", 0.75));
endfunction

%% Uniform background (same size)
function [ data, truth ] = data_unibg_ss(dims, extra)
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
  [ data, truth ] = gen_data(struct("dimensions", dims,

				    "noise_dist", P_UNIFORM,
				    "noise_size", noise_size,
				    "noise_mean", 0.0,
				    "noise_var",  2.0,

				    "signal_dist",  P_GAUSSIAN,
				    "signal_size",  signal_sizes,
				    "signal_var",   signal_var * 0.125,
				    "signal_mean",  0.0,
				    "signal_shift", 0.75,
				    "signal_space", 0.75));
endfunction

%% Uniform background (random sizes)
function [ data, truth ] = data_unibg_rs(dims, extra)
  %% Sizes
  groups      = floor(   1 +   5 * rand())
  signal_size = round( 150 +  50 * randn(1, groups))
  noise_size  = round(1500 + 500 * randn())

  %% Generate
  [ data, truth ] = gen_data(struct("dimensions", dims,

				    "noise_dist", P_UNIFORM,
				    "noise_size", noise_size,
				    "noise_mean", 0.0,
				    "noise_var",  2.0,

				    "signal_dist",  P_GAUSSIAN,
				    "signal_size",  signal_size,
				    "signal_var",   0.125,
				    "signal_mean",  0.0,
				    "signal_shift", 0.75,
				    "signal_space", 0.75));
endfunction

%% Gaussian background
function [ data, truth ] = data_gaussbg(dims, extra)
  %% Generate it
  [ data, truth ] = gen_data(struct("dimensions", dims,

				    "noise_dist", P_SPHERICAL,
				    "noise_size", 1000 * 2 ^ dims,
				    "noise_mean", 0.0,
				    "noise_var",  2.0,

				    "signal_dist",  P_GAUSSIAN,
				    "signal_size",  [ 100, 150, 150, 200 ],
				    "signal_var",   0.125,
				    "signal_mean",  0.0,
				    "signal_shift", 0.75,
				    "signal_space", 0.75));
endfunction

%% Bernoullis
function [ data, truth ] = data_bernoulli(dims, extra)
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
endfunction

%% Special 1
function [ data, truth ] = data_special1(dims, extra)
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
endfunction

%% Map
data_gen = struct("unibg",     @data_unibg,
		  "unibg_ss",  @data_unibg_ss,
		  "unibg_rs",  @data_unibg_rs,
		  "gaussbg",   @data_gaussbg,
		  "bernoulli", @data_bernoulli,
		  "special1",  @data_special1);


%%%%%%%%%%
%% Main %%
%%%%%%%%%%

%% Get the parameters
args = argv();
if length(args) ~= 5
  error(cstrcat("Wrong number of arguments:", ...
		" Expected <generator> <extra> <dimensions> <seed> <output>"));
endif

%% Generator
gen = args{1};
if ~isfield(data_gen, gen)
  error("Wrong generator name '%s'. Must be: ", gen, fields(data_gen));
endif

%% Extra arguments
extra = regex_split(args{2}, '(,|\s+,)\s*');

%% Dimensions
[ dims, status ] = str2double(args{3});
if status ~= 0
  error("Wrong number of dimensions '%s'", args{3})
endif

%% Seed
[ seed, status ] = str2double(args{4});
if status ~= 0
  error("Wrong seed '%s'", args{4});
endif

%% Output
output = args{5};

%% Initialize seed
set_all_seeds(seed);

%% Generate
genfun = getfield(data_gen, gen);
[ data, truth ] = genfun(dims, extra);

%% Save
try
  save("-binary", "-zip", output, "data", "truth");
catch
  error("Cannot save data to '%s': %s", output, lasterr());
end_try_catch
