%% -*- mode: octave; -*-

%% Generate the data from
%% Shin Ando
%% "Clustering Needles in a Haystack: An Information Theoretic
%%  Analysis of Minority And Outlier Detection"
%% 7th IEEE Conference on Data Mining, 2007

%% Author: Edgar Gonzàlez i Pellicer


%% Octopus
pkg load octopus;


%%%%%%%%%%%%%%%%%%%%%
%% Data Generation %%
%%%%%%%%%%%%%%%%%%%%%

%% Distributions
enum P_BERNOULLI P_GAUSSIAN P_SPHERICAL P_UNIFORM

%% Uniform background
function [ data, truth ] = data_unibg(dims)
  %% Generate it
  [ data, truth ] = gen_data(struct("dimensions", dims,

				    "noise_dist", P_UNIFORM,
				    "noise_size", 1000 * 2 ^ dims,
				    "noise_mean", 0.0,
				    "noise_var",  1.0,

				    "signal_dist",  P_GAUSSIAN,
				    "signal_size",  [ 100, 150, 150, 200 ],
				    "signal_var",   0.125,
				    "signal_mean",  0.0,
				    "signal_shift", 0.5));
endfunction

%% Gaussian background
function [ data, truth ] = data_gaussbg(dims)
  %% Generate it
  [ data, truth ] = gen_data(struct("dimensions", dims,

				    "noise_dist", P_SPHERICAL,
				    "noise_size", 1000 * 2 ^ dims,
				    "noise_mean", 0.0,
				    "noise_var",  1.0,

				    "signal_dist",  P_GAUSSIAN,
				    "signal_size",  [ 100, 150, 150, 200 ],
				    "signal_var",   0.125,
				    "signal_mean",  0.0,
				    "signal_shift", 0.5));
endfunction

%% Special 1
%% From http://www.cs.umbc.edu/~squire/reference/polyhedra.shtml
function [ data, truth ] = data_special1(dims)
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
data_gen = struct("unibg",    @data_unibg,
		  "gaussbg",  @data_gaussbg,
		  "special1", @data_special1);


%%%%%%%%%%
%% Main %%
%%%%%%%%%%

%% Get the parameters
args = argv();
if length(args) ~= 4
  error(cstrcat("Wrong number of arguments:", ...
		" Expected <generator> <dimensions> <seed> <output>"));
endif

%% Generator
gen = args{1};
if ~isfield(data_gen, gen)
  error("Wrong generator name '%s'", gen);
endif

%% Dimensions
[ dims, status ] = str2double(args{2});
if status ~= 0
  error("Wrong number of dimensions '%s'", args{2})
endif

%% Seed
[ seed, status ] = str2double(args{3});
if status ~= 0
  error("Wrong seed '%s'", args{3});
endif

%% Output
output = args{4};

%% Initialize seed
rand("seed", seed);

%% Generate
genfun = getfield(data_gen, gen);
[ data, truth ] = genfun(dims);

%% Save
try
  save("-binary", "-zip", output, "data", "truth");
catch
  error("Cannot save data to '%s': %s", output, lasterr());
end_try_catch
