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

%% Map
data_gen = struct("unibg",   @data_unibg,
		  "gaussbg", @data_gaussbg);


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
