%% -*- mode: octave; -*-

%% Octopus
pkg load octopus;

%% Distributions
enum P_BERNOULLI P_GAUSSIAN P_SPHERICAL P_UNIFORM


%%%%%%%%%%
%% Main %%
%%%%%%%%%%

%% Default options
def_opts            = struct();
def_opts.k_max      = 100;   % Maximum number of groups
def_opts.rbf_gamma  =  10.0; % Gamma for RBF kernel
def_opts.soft_alpha =  10.0; % Alpha for Voronoi
def_opts.n_samples  =  10;   % Number of samples
def_opts.n_repeats  =  25;   % Number of repetitions per sample
def_opts.verbose    = false;

%% Parse options
[ cmd_args, cmd_opts ] = ...
    get_options(def_opts, ...
		"k-max=i",      "k_max",      ...
		"rbf-gamma=f",  "rbf_gamma",  ...
		"soft-alpha=f", "soft_alpha", ...
		"n-samples=i",  "n_samples",  ...
		"n-repeats=i",  "n_repeats",  ...
		"verbose!",     "verbose");

%% Check the number
if length(cmd_args) ~= 6
  error(strcat("Wrong number of arguments: Expected: [options]",
	       " <family> <generator> <extra> <dimensions> <seed> <output>"));
endif

%% Family
family = cmd_args{1};
if ~strcmp(family, "ando") && ~strcmp(family, "toy")
  error(sprintf("Wrong family name '%s'"), family);
endif

%% Generator
generator = cmd_args{2};

%% Extra
extra = regex_split(cmd_args{3}, '(,|\s+,)\s*');

%% Dimensions
dims = parse_double(cmd_args{4}, "number of dimensions");

%% Seed
seed = parse_double(cmd_args{5}, "seed");

%% Output
output = cmd_args{6};


%% Set all seeds
set_all_seeds(seed);


%% Distances
rbf_dist = KernelDistance(RBFKernel(cmd_opts.rbf_gamma));

%% Create clustering methods
methods = ...
    struct("rproj", ...
	       RandomProj(struct("soft_alpha", nan)), ...
	   "hvoro_mah", @(data) ...
	       Voronoi(MahalanobisDistance(data), ...
		       struct("soft_alpha", nan)), ...
	   "hvoro_rbf", ...
	       Voronoi(rbf_dist, struct("soft_alpha", nan)), ...
	   "voro_mah", @(data) ...
	       Voronoi(MahalanobisDistance(data), ...
		       struct("soft_alpha", cmd_opts.soft_alpha)), ...
	   "voro_rbf", ...
	       Voronoi(rbf_dist, struct("soft_alpha", cmd_opts.soft_alpha)));
           %% "hproj", ...
	   %%     RandomProj(struct("soft_alpha", nan,
	   %% 			 "homogeneous", true())), ...
	   %% "bern", ...
	   %%    Bernoulli(), ...
	   %% "kmeans_mah", @(data) ...
	   %%     KMeans(MahalanobisDistance(data), ...
	   %% 	      struct("change_threshold", 0.1)), ...
	   %% "kmeans_rbf", ...
	   %%     KMeans(rbf_dist, struct("change_threshold", 0.1)), ...

%% Names
names = fieldnames(methods);


%% Affinity matrices
affinities = struct();

%% Sizes
cl_sizes = [];
total    = 0;

%% For each sample
for s = 1 : cmd_opts.n_samples
  %% Generate the data
  if strcmp(family, "ando")
    if s == 1
      [ data, truth, ando_desc ] = ando_data(generator, dims, extra);
    else
      [ data, truth ] = gen_data(ando_desc);
    endif
  else %% strcmp(family, "toy")
    [ data, truth ] = toy_data(generator);
  endif

  %% Is it the first?
  if s == 1
    %% Number of clusters
    n_clusters = max(truth);

    %% Initialize the affinity matrices
    for i = 1 : length(names)
      name       = names{i};
      affinities = setfield(affinities, name, zeros(n_clusters, n_clusters));
    endfor

    %% Initialize the sizes
    cl_sizes = zeros(n_clusters, 1);
  end

  %% Update data count
  n_data = length(truth);
  total += n_data;

  %% Sparse truth
  sp_truth = sparse(truth, 1 : n_data, ones(1, n_data));

  %% Add to cluster sizes
  cl_sizes += sum(sp_truth, 2);

  %% For each method
  for i = 1 : length(names)
    name = names{i};

    %% Get the method
    met = getfield(methods, name);
    if isfunctionhandle(met)
      met = met(data);
    endif

    % Initialize co-occurence
    co_occ = zeros(n_data, n_data);

    %% For each repetition
    for r = 1 : cmd_opts.n_repeats
      %% Log
      if cmd_opts.verbose
	fprintf(2, "Sample: %-3d Method: %-15s Repeat: %-3d\n", s, name, r);
      endif

      %% Get the number of groups
      k = floor(2 + (cmd_opts.k_max - 1) * rand());

      %% Call it
      [ expec ] = cluster(met, data, k);

      %% Co-occurrence matrix
      co_occ += expec' * expec;
    endfor

    %% Log
    if cmd_opts.verbose
      fprintf(2, "Sample: %-3d Method: %-15s Average\n", s, name);
    endif

    %% Average co-occurrence
    co_occ /= cmd_opts.n_repeats;

    %% Affinity
    met_aff    = getfield(affinities, name);
    met_aff   += affinity(co_occ, truth);
    affinities = setfield(affinities, name, met_aff);
  endfor
endfor

%% Find cluster a priori probabilities
alpha = cl_sizes / total;

%% For each method
for i = 1 : length(names)
  name = names{i};

  %% Log
  if cmd_opts.verbose
    fprintf(2, "Final Method: %-15s\n", name);
  endif

  %% Average affinities
  met_aff    = getfield(affinities, name);
  met_aff   /= cmd_opts.n_samples;
  affinities = setfield(affinities, name, met_aff);
endfor

%% Save
try
  save("-binary", "-zip", output, "alpha", "affinities");
catch
  error("Cannot save data to '%s': %s", output, lasterr());
end_try_catch
