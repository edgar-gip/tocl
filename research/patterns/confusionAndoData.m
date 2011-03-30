% -*- mode: octave; -*-

%% Minority clustering of data

%% Author: Edgar Gonzàlez i Pellicer


%% Division by zero
%% warning error Octave:divide-by-zero;

%% Octopus
pkg load octopus;

%% Ando elements
source(binrel("andoElements.m"));


%%%%%%%%%%
%% Main %%
%%%%%%%%%%

%% Options
def_opts = struct();
def_opts.fg_only = false();

%% Parse options
[ args, opts ] = ...
    get_options(def_opts, ...
		"fg-only!", "fg_only");

%% Check parameter length
if length(args) ~= 7
  error(cstrcat("Wrong number of arguments: Expected [options]", ...
		" <input> <distance> <d-extra> <method> <m-extra>", ...
		" <k> <seed>"));
endif

%% Input file
input = args{1};
try
  load(input, "data", "truth");
catch
  error("Cannot load data from '%s': %s", input, lasterr());
end_try_catch

%% Distance
dist = args{2};
if ~isfield(distances, dist)
  error("Wrong distance name '%s'. Must be: %s", dist, fields(distances));
endif

%% Extra arguments
dextra = regex_split(args{3}, '(,|\s+,)\s*');

%% Method
met = args{4};
if ~isfield(methods, met)
  error("Wrong method name '%s'. Must be: %s", met, fields(methods));
endif

%% Extra arguments
mextra = regex_split(args{5}, '(,|\s+,)\s*');

%% Enough args?
req_args = getfield(methods, met, "args");
if length(mextra) ~= req_args
  error("Method '%s' requires %d extra arg(s): %s",
	met, req_args, getfield(methods, met, "help"));
endif

%% k
[ k, status ] = str2double(args{6});
if status ~= 0
  error("Wrong number of clusters '%s'", args{6})
endif

%% Seed
[ seed, status ] = str2double(args{7});
if status ~= 0
  error("Wrong seed '%s'", args{7});
endif


%% Initialize seed
set_all_seeds(seed);

%% Create distance
distfun = getfield(distances, dist);
if isfunctionhandle(distfun)
  distance = distfun(data, dextra);
else
  distance = distfun;
endif

%% Truth information
n_data = length(truth);
struth = truth > 1;

%% Foreground only?
if opts.fg_only
  data   = data(:, struth);
  truth  = truth(struth) - 1;
  n_data = length(truth);
  struth = ones(1, n_data);
endif

%% Create clusterer
clustfun  = getfield(methods, met, "make");
clusterer = clustfun(distance, data, struth, mextra);

%% Cluster
[ total0, user0, system0 ] = cputime();
[ expec, model ] = cluster(clusterer, data, k);
[ total1, user1, system1 ] = cputime();

%% Time difference
cluster_time = total1 - total0;

%% Harden the expectation
hexpec = harden_expectation(expec, true());

%% Complete confusion matrix
complete = full(sparse(     truth, 1 : n_data, ones(1, n_data)) * hexpec');
disp("Complete:"); disp(complete); disp("");

%% Simple confusion matrix
simple   = full(sparse(1 + struth, 1 : n_data, ones(1, n_data)) * hexpec');
disp("Simple:");   disp(simple);
