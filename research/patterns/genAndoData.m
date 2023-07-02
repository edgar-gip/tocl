%% -*- mode: octave; -*-

%% Generate the data from
%% Shin Ando
%% "Clustering Needles in a Haystack: An Information Theoretic
%%  Analysis of Minority And Outlier Detection"
%% 7th IEEE Conference on Data Mining, 2007

%% Author: Edgar Gonzàlez i Pellicer


%% Octopus
pkg load octopus;

%% Distributions
enum P_BERNOULLI P_GAUSSIAN P_SPHERICAL P_UNIFORM


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
generator = args{1};

%% Extra arguments
extra = regex_split(args{2}, '(,|\s+,)\s*');

%% Dimensions
dims = parse_double(args{3}, "number of dimensions");

%% Seed
seed = parse_double(args{4}, "seed");

%% Output
output = args{5};

%% Initialize seed
set_all_seeds(seed);

%% Generate
[ data, truth ] = ando_data(generator, dims, extra);

%% Save
try
  save("-binary", "-zip", output, "data", "truth");
catch
  error("Cannot save data to '%s': %s", output, lasterr());
end_try_catch
