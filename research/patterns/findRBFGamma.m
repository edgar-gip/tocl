%% -*- mode: octave; -*-


%% Octopus
pkg load octopus;


%%%%%%%%%%%%%%%%%%%%%%%%%
%% Gamma determination %%
%%%%%%%%%%%%%%%%%%%%%%%%%

%% Find the partition coefficient
function [ pc ] = partition_coefficient(distances, rbf_gamma, soft_alpha)
  %% Apply RBF
  %% From RBFKernel/apply
  distances *= -rbf_gamma;
  distances  = exp(distances);

  %% Hard or soft?
  %% From VoronoiModel/expectation
  if isfinite(soft_alpha)
    %% Soft
    expec = distance_probability(soft_alpha, -distances);
  else
    %% Hard
    expec = distance_winner(-distances);
  endif

  %% Find the pc
  pc = sum(sum(expec .* expec));
endfunction


%%%%%%%%%%%%%
%% Options %%
%%%%%%%%%%%%%

%% Set clusters
function [ opts ] = s_clusters(opts, value)
  opts.min_clusters = opts.max_clusters = value;
endfunction

%% Set hard alpha
function [ opts ] = s_hard_alpha(opts, value)
  opts.soft_alpha = inf;
endfunction

%% Default options
def_opts                 = struct();
def_opts.seed            = [];
def_opts.sparse          = false();
def_opts.min_clusters    = 2;
def_opts.max_clusters    = 20;
def_opts.ensemble_size   = 100;
def_opts.min_rbf_gamma   = 0.1;
def_opts.max_rbf_gamma   = 10.0;
def_opts.rbf_gamma_steps = 20;
def_opts.soft_alpha      = 0.1;

%% Parse options
[ cmd_args, cmd_opts ] = ...
    get_options(def_opts, ...
		"seed=f",             "seed",            ...
		"sparse!",            "sparse",          ...
		"min-clusters=i",     "min_clusters",    ...
		"max-clusters=i",     "max_clusters",    ...
		"clusters=i",         @s_clusters,       ...
		"ensemble-size=i",    "ensemble_size",   ...
	 	"min-rbf-gamma=f",    "min_rbf_gamma",   ...
	 	"max-rbf-gamma=f",    "max_rbf_gamma",   ...
	 	"rbf-gamma-steps=f",  "rbf_gamma_steps", ...
		"hard-alpha",         @s_hard_alpha,     ...
		"soft-alpha=f",       "soft_alpha");

%% Arguments
if length(cmd_args) < 1
  error("Must provide a file");
endif


%% Set a seed
if isempty(cmd_opts.seed)
  cmd_opts.seed = floor(1000.0 * rand());
endif

%% Initialize seed
rand("seed", cmd_opts.seed);

% Number of clusters range
range_clusters = cmd_opts.max_clusters - cmd_opts.min_clusters;


%% Distance
sqe = SqEuclideanDistance();


%% For each file
for input = cmd_args
  %% Load it
  try
    if cmd_opts.sparse
      [ data, truth ] = read_sparse(input{1}, true());
    else
      load(input{1}, "data", "truth");
    endif
  catch
    error("Cannot load data from '%s': %s", input{1}, lasterr());
  end_try_catch

  %% Sizes
  [ n_dims, n_data ] = size(data);

  %% Sum for average
  sum_gamma = 0;

  %% Generate that many ensembles
  for e = 1 : cmd_opts.ensemble_size
    %% Number of clusters
    k = floor(cmd_opts.min_clusters + (range_clusters + 1) * rand());

    %% Select seeds
    seeds = sort(randperm(n_data)(1 : k));

    %% Distances
    dists = apply(sqe, data(:, seeds), data);

    %% Starting pc
    max_gamma = cmd_opts.min_rbf_gamma;
    max_pc    = partition_coefficient(dists, cmd_opts.min_rbf_gamma, ...
				      cmd_opts.soft_alpha);

    %% For each (other) gamma
    gamma_f = (cmd_opts.max_rbf_gamma / cmd_opts.min_rbf_gamma) ^ ...
	      (1 / cmd_opts.rbf_gamma_steps);
    for s = 1 : cmd_opts.rbf_gamma_steps
      %% Gamma
      gamma = cmd_opts.min_rbf_gamma * gamma_f ^ s;

      %% Find
      pc = partition_coefficient(dists, gamma, cmd_opts.soft_alpha);

      %% Update
      if pc > max_pc
	max_gamma = gamma;
	max_pc    = pc;
      endif
    endfor

    %% Display max
    fprintf(2, "%s %d %d %g %g\n", input{1}, e, k, max_gamma, max_pc);

    %% Update sum
    sum_gamma += max_gamma;
  endfor

  %% Display average
  printf("%s * * %g *\n", input{1}, sum_gamma / cmd_opts.ensemble_size);
endfor