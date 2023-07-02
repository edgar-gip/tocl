%% -*- mode: octave; -*-


%% Octopus
pkg load octopus;

%% Add private functions
addpath("./private");

%% Methods
enum M_ALL M_ENSEMBLE_VARIANCE M_MEAN_DIST M_NEIGHBOUR M_PC M_VARIANCE


%%%%%%%%%%%%%%%%%%%%%%%%%
%% Criterion functions %%
%%%%%%%%%%%%%%%%%%%%%%%%%

%% Find the partition coefficient
function [ pc ] = partition_coefficient(distances, soft_alpha, rbf_gamma)

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

%% Find the distance variance
function [ dv ] = distance_variance(distances, rbf_gamma)

  %% Apply RBF
  %% From RBFKernel/apply
  distances *= -rbf_gamma;
  distances  = exp(distances);

  %% Variance
  dv = var(reshape(distances, 1, numel(distances)));
endfunction


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Criterion-based search %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Search gamma via criterion
function [ max_gamma, max_crit ] = ...
      search_gamma_crit(dists, criterion, cmd_opts)

  %% Best so far
  max_gamma =  nan;
  max_crit  = -inf;

  %% Starting bounds
  max_rbf_gamma = cmd_opts.max_rbf_gamma;
  min_rbf_gamma = cmd_opts.min_rbf_gamma;

  %% Recursivity
  for r = 1 : cmd_opts.rbf_gamma_rec
    %% Factor
    gamma_f = (max_rbf_gamma / min_rbf_gamma) ^ ...
              (1 / cmd_opts.rbf_gamma_steps);

    %% Display
    if cmd_opts.verbose
      fprintf(2, "[ %g .. %g ]\n", min_rbf_gamma, max_rbf_gamma);
    endif

    %% For each one
    for s = 0 : cmd_opts.rbf_gamma_steps
      %% Gamma
      gamma = min_rbf_gamma * gamma_f ^ s;

      %% Find
      crit = criterion(dists, gamma);

      %% Display
      if cmd_opts.verbose
        fprintf(2, "  %g: %g\n", gamma, crit);
      endif

      %% Update
      if crit > max_crit
        max_gamma = gamma;
        max_crit  = crit;
      endif
    endfor

    %% Update min and max
    max_rbf_gamma = max_gamma * gamma_f;
    min_rbf_gamma = max_gamma / gamma_f;
  endfor
endfunction

%% Find gamma via ensemble criterion search
function [ best_gamma ] = find_gamma_ensemble_crit(data, criterion, cmd_opts)

  %% Sizes
  [ n_dims, n_data ] = size(data);

  %% Squared euclidean distance
  sqe = SqEuclideanDistance();

  %% Number of clusters range
  range_clusters = cmd_opts.max_clusters - cmd_opts.min_clusters;

  %% Sum for average
  sum_max_gamma = 0;

  %% Generate that many ensembles
  for e = 1 : cmd_opts.ensemble_size
    %% Number of clusters
    k = floor(cmd_opts.min_clusters + (range_clusters + 1) * rand());

    %% Select seeds
    seeds = sort(randperm(n_data)(1 : k));

    %% Distances
    dists = apply(sqe, data(:, seeds), data);

    %% Find it
    [ max_gamma, max_crit ] = ...
        search_gamma_crit(dists, criterion, cmd_opts);

    %% Display max
    if cmd_opts.verbose
      fprintf(2, "%d %d %g %g\n", e, k, max_gamma, max_crit);
    endif

    %% Update sum
    sum_max_gamma += max_gamma;
  endfor

  %% Average
  best_gamma = sum_max_gamma / cmd_opts.ensemble_size;
endfunction

%% Find gamma via criterion search
function [ best_gamma ] = find_gamma_crit(data, criterion, cmd_opts)

  %% Sizes
  [ n_dims, n_data ] = size(data);

  %% Subsample?
  if n_data > cmd_opts.subsample
    indices = randperm(n_data)(1 : cmd_opts.subsample);
    data    = data(:, indices);
    n_data  = cmd_opts.subsample;
  endif

  %% Squared euclidean distance
  sqe = SqEuclideanDistance();

  %% Distances
  dists = apply(sqe, data);

  %% Find it
  [ best_gamma, max_crit ] = ...
      search_gamma_crit(dists, criterion, cmd_opts);

  %% Display max
  if cmd_opts.verbose
    fprintf(2, "%g %g\n", max_gamma, max_crit);
  endif
endfunction


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Neighbour-based determination %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Find gamma via the Neighbour method
function [ best_gamma ] = find_gamma_neighbour(data, cmd_opts)

  %% Sizes
  [ n_dims, n_data ] = size(data);

  %% Subsample?
  if n_data > cmd_opts.subsample
    indices = randperm(n_data)(1 : cmd_opts.subsample);
    data    = data(:, indices);
    n_data  = cmd_opts.subsample;
  endif

  %% Squared euclidean distance
  sqe = SqEuclideanDistance();

  %% Distances
  dists = apply(sqe, data);

  %% Total number of neighbours (or cut_idx)
  cut_idx = min(n_data * n_data, n_data * cmd_opts.neighbours);

  %% Sort them all, and take the cut
  dists    = sort(reshape(dists, 1, n_data * n_data));
  cut_dist = dists(cut_idx);

  %% Display it
  if cmd_opts.verbose
    %% Display
    fprintf(2, "%d/%d - %g\n", cut_idx, n_data * n_data, cut_dist);
  endif

  %% Now, 2 * (1 - exp(-gamma * cut_dist)) = neighbour_dist
  best_gamma = -log(1 - cmd_opts.neighbour_dist) / cut_dist;
endfunction


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Mean-distance-based determination %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Find gamma via the Mean Distance method
function [ best_gamma ] = find_gamma_mean_dist(data, cmd_opts)

  %% Sizes
  [ n_dims, n_data ] = size(data);

  %% Subsample?
  if n_data > cmd_opts.subsample
    indices = randperm(n_data)(1 : cmd_opts.subsample);
    data    = data(:, indices);
    n_data  = cmd_opts.subsample;
  endif

  %% Squared euclidean distance
  sqe = SqEuclideanDistance();

  %% Distances
  dists = apply(sqe, data);

  %% Mean
  mean_dist = mean(reshape(dists, 1, n_data * n_data));

  %% Display it
  if cmd_opts.verbose
    %% Display
    fprintf(2, "%g\n", mean_dist);
  endif

  %% Now, 2 * (1 - exp(-gamma * mean_dist)) = neighbour_dist
  best_gamma = -log(1 - cmd_opts.neighbour_dist) / mean_dist;
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
def_opts.method          = M_PC;
def_opts.min_clusters    = 2;
def_opts.max_clusters    = 20;
def_opts.ensemble_size   = 100;
def_opts.min_rbf_gamma   = 0.1;
def_opts.max_rbf_gamma   = 10.0;
def_opts.rbf_gamma_steps = 10;
def_opts.rbf_gamma_rec   = 3;
def_opts.soft_alpha      = 0.1;
def_opts.neighbours      = 20;
def_opts.neighbour_dist  = 0.9;
def_opts.subsample       = 5000;
def_opts.verbose         = false();

%% Parse options
[ cmd_args, cmd_opts ] = ...
    get_options(def_opts, ...
                "seed=f",             "seed",            ...
                "sparse!",            "sparse",          ...
                "all=r0",             "method",          ...
                "e-variance=r1",      "method",          ...
                "mean-distance=r2",   "method",          ...
                "neighbour=r3",       "method",          ...
                "pc=r4",              "method",          ...
                "variance=r5",        "method",          ...
                "min-clusters=i",     "min_clusters",    ...
                "max-clusters=i",     "max_clusters",    ...
                "clusters=i",         @s_clusters,       ...
                "ensemble-size=i",    "ensemble_size",   ...
                "min-rbf-gamma=f",    "min_rbf_gamma",   ...
                "max-rbf-gamma=f",    "max_rbf_gamma",   ...
                "rbf-gamma-steps=f",  "rbf_gamma_steps", ...
                "rbf_gamma_rec=i",    "rbf_gamma_rec",   ...
                "hard-alpha",         @s_hard_alpha,     ...
                "soft-alpha=f",       "soft_alpha",      ...
                "neighbours=i",       "neighbours",      ...
                "neighbour-dist=f",   "neighbour_dist",  ...
                "subsample=i",        "subsample",       ...
                "verbose!",           "verbose");

%% Arguments
if length(cmd_args) < 1
  error("Must provide a file");
endif


%% Set a seed
if isempty(cmd_opts.seed)
  cmd_opts.seed = floor(1000.0 * rand());
endif

%% Initialize seed
set_all_seeds(cmd_opts.seed);

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

  %% Find it
  if cmd_opts.method == M_ALL
    %% Display all
    printf("%s EVar %g\n", input{1}, ...
           find_gamma_ensemble_crit(data, @distance_variance, cmd_opts));
    printf("%s Mean %g\n", input{1}, ...
           find_gamma_mean_dist(data, cmd_opts));
    printf("%s Neig %g\n", input{1}, ...
           find_gamma_neighbour(data, cmd_opts));
    printf("%s PrtC %g\n", input{1}, ...
           find_gamma_ensemble_crit ...
           (data, @(data, gamma) ...
            partition_coefficient(data, cmd_opts.soft_alpha, gamma), ...
            cmd_opts));
    printf("%s Vari %g\n", input{1}, ...
           find_gamma_crit(data, @distance_variance, cmd_opts));

  else
    %% Which one?
    switch cmd_opts.method
      case M_ENSEMBLE_VARIANCE
        gamma = find_gamma_ensemble_crit(data, @distance_variance, cmd_opts);

      case M_MEAN_DIST
        gamma = find_gamma_mean_dist(data, cmd_opts);

      case M_NEIGHBOUR
        gamma = find_gamma_neighbour(data, cmd_opts);

      case M_PC
        gamma = ...
            find_gamma_ensemble_crit ...
            (data, @(data, gamma) ...
             partition_coefficient(data, cmd_opts.soft_alpha, gamma), ...
             cmd_opts);

      case M_VARIANCE
        gamma = find_gamma_crit(data, @distance_variance, cmd_opts);
    endswitch

    %% Display average
    printf("%s %g\n", input{1}, gamma);
  endif
endfor
