%% -*- mode: octave; -*-

%% Fraction of pairs that are in the same class

%% Author: Edgar Gonzàlez i Pellicer


%% Octopus
pkg load octopus


%%%%%%%%%%%
%% Enums %%
%%%%%%%%%%%

%% Task
enum T_SAME_SIDE T_SCORE_HISTO

%% Distributions
enum P_BERNOULLI P_GAUSSIAN P_UNIFORM

%% Inside weak clustering methods
%% enum C_BERNOULLI C_KMEANS C_SVM C_VORONOI
enum C_BERNOULLI C_VORONOI

%% Distance
enum D_EUCLIDEAN D_KERNEL D_MAHALANOBIS

%% Kernels
enum K_LINEAR K_POLYNOMIAL K_RBF


%%%%%%%%%%%%%
%% Options %%
%%%%%%%%%%%%%

%% Set signal-size
function [ opts ] = s_signal_size(opts, value)
  opts.signal_size = cellfun(@str2double, regex_split(value, '(,|\s+,)\s*'));
endfunction

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
def_opts.task            = T_SAME_SIDE;
def_opts.seed            = [];
def_opts.outer_runs      = 5;
def_opts.inner_runs      = 100;
def_opts.do_plot         = false();
def_opts.pause_time      = 1;
def_opts.dimensions      = 2;
def_opts.noise_size      = 1000;
def_opts.noise_dist      = P_UNIFORM;
def_opts.noise_mean      = 0.0;
def_opts.noise_var       = 5.0;
def_opts.signal_groups   = 1;
def_opts.signal_size     = 100;
def_opts.signal_dist     = P_GAUSSIAN;
def_opts.signal_shift    = 2.5;
def_opts.signal_var      = 1.0;
def_opts.min_clusters    = 2;
def_opts.max_clusters    = 20;
def_opts.ensemble_size   = 100;
def_opts.clusterer       = C_VORONOI;
def_opts.em_iterations   = 100;       %% For C_BERNOULLI
def_opts.em_threshold    = 1e-6;      %% For C_BERNOULLI
def_opts.distance        = D_KERNEL;  %% For C_VORONOI
def_opts.kernel          = K_RBF;     %% For D_KERNEL
def_opts.poly_degree     = 2;         %% For K_POLYNOMIAL
def_opts.poly_constant   = true();    %% For K_POLYNOMIAL
def_opts.rbf_gamma       = 0.1;       %% For K_RBF
def_opts.soft_alpha      = 0.1;       %% For C_VORONOI
def_opts.histo_bins      = 100;

%% Parse options
[ cmd_args, cmd_opts ] = ...
    get_options(def_opts, ...
		"same-side=r0",       "task",          ...
		"score-histo=r1",     "task",          ...
		"seed=f",             "seed",          ...
		"outer-runs=i",       "outer_runs",    ...
		"inner-runs=i",       "inner_runs",    ...
		"do-plot!",           "do_plot",       ...
		"pause-time=f",       "pause_time",    ...
		"dimensions=i",       "dimensions",    ...
		"noise-size=i",       "noise_size",    ...
		"noise-bernoulli=r0", "noise_dist",    ...
		"noise-gaussian=r1",  "noise_dist",    ...
		"noise-uniform=r2",   "noise_dist",    ...
		"noise-mean=f",       "noise_mean",    ...
		"noise-var=f",        "noise_var",     ...
		"signal-groups=i",    "signal_groups", ...
		"signal-size=s",      @s_signal_size,  ...
		"signal-bernoulli=r0","signal_dist",   ...
		"signal-gaussian=r1", "signal_dist",   ...
		"signal-uniform=r2",  "signal_dist",   ...
		"signal-shift=f",     "signal_shift",  ...
		"signal-var=f",       "signal_var",    ...
		"min-clusters=i",     "min_clusters",  ...
		"max-clusters=i",     "max_clusters",  ...
		"ensemble-size=i",    "ensemble_size", ...
		"clusters=i",         @s_clusters,     ...
		"bernoulli=r0",       "clusterer",     ...
		"voronoi=r1",         "clusterer",     ...
		"em-iterations=i",    "em_iterations", ...
		"em-threshold=f",     "em_threshold",  ...
		"euclidean-dist=r0",  "distance",      ...
		"kernel-dist=r1",     "distance",      ...
		"linear-kernel=r0",   "kernel",        ...
		"poly-kernel=r1",     "kernel",        ...
		"rbf-kernel=r2",      "kernel",        ...
		"poly-degree=i",      "poly_degree",   ...
		"poly-constant!",     "poly_constant", ...
	 	"rbf-gamma=f",        "rbf_gamma",     ...
		"hard-alpha",         @s_hard_alpha,   ...
		"soft-alpha=f",       "soft_alpha",    ...
		"histo-bins=i",       "histo_bins");

%% Chek number of arguments
if length(cmd_args) ~= 0
  error("Wrong number of arguments (should be 0)");
endif

%% Set a seed
if isempty(cmd_opts.seed)
  cmd_opts.seed = floor(1000.0 * rand());
endif

%% No plots for more than three dimensions
if cmd_opts.dimensions > 3
  warning("Cannot plot more than three dimensional data");
  cmd_opts.do_plot = false();
endif

%% Expand signal_size
if length(cmd_opts.signal_size) == 1
  cmd_opts.signal_size = ...
      cmd_opts.signal_size * ones(1, cmd_opts.signal_groups);
else
  cmd_opts.signal_groups = length(cmd_opts.signal_size);
endif

% Number of clusters range
cmd_opts.range_clusters = cmd_opts.max_clusters - cmd_opts.min_clusters;


%%%%%%%%%%%%%%%%%%%%%
%% Data generation %%
%%%%%%%%%%%%%%%%%%%%%

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
  %% project   = rand(dims, dims) - 0.5;
  %% project ./= ones(dims, 1) * sqrt(sum(project .* project));
  %% variance  = project * diag(var * rand(dims, 1), 0);
  variance = var * eye(dims);

  %% Data
  data = mean * ones(1, size) + variance * randn(dims, size);
endfunction

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
      data(:, 1 : cmd_opts.noise_size) = ...
	  gen_bernoulli(cmd_opts.dimensions, cmd_opts.noise_size, ...
			cmd_opts.noise_mean);
    case P_GAUSSIAN
      data(:, 1 : cmd_opts.noise_size) = ...
	  gen_gaussian(cmd_opts.dimensions, cmd_opts.noise_size, ...
		       eff_noise_mean, cmd_opts.noise_var);
    case P_UNIFORM
      data(:, 1 : cmd_opts.noise_size) = ...
	  gen_uniform(cmd_opts.dimensions, cmd_opts.noise_size, ...
		      eff_noise_mean, cmd_opts.noise_var);
  endswitch

  %% Signal
  cl   = 2;
  base = cmd_opts.noise_size;
  for cur_size = cmd_opts.signal_size
    %% Effective signal mean
    eff_signal_mean = ...
	eff_noise_mean + gen_gaussian(cmd_opts.dimensions, 1, ...
				      0, cmd_opts.signal_shift);

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
endfunction


%%%%%%%%%%%%%%
%% Plotting %%
%%%%%%%%%%%%%%

%% Do the expectation plot
function do_plot_expec(window, data, expec, pause_time)
  %% Sizes
  [ dims, elems ] = size(data);
  [ k,    elems ] = size(expec);

  %% Plots
  plots = {};

  %% For each cl
  for cl = 1 : k
    %% Elements
    cluster = find(expec(cl, :));

    %% Add their data
    if dims == 2
      plots = cell_push(plots, ...
			data(1, cluster), data(2, cluster), "x");
    else %% dims == 3
      plots = cell_push(plots, ...
			data(1, cluster), data(2, cluster), ...
			data(3, cluster), "x");
    endif
  endfor

  %% Plot
  figure(window);
  if dims == 2
    plot(plots{:});
  else
    plot3(plots{:});
  endif

  %% Stop?
  if pause_time > 0
    pause(pause_time);
  endif
endfunction

%% Do the sorted score plot
function do_plot_sorted_score(window, scores, pause_time)
  %% Plot
  figure(window);
  plot(sort(scores, "descend"), "-");

  %% Stop?
  if pause_time > 0
    pause(pause_time);
  endif
endfunction

%% Do the score plot
function do_plot_score(window, scores, expec, histo_bins, pause_time)
  %% Sizes
  [ k, elems ] = size(expec);

  %% Min/max
  min_score = min(scores);
  max_score = max(scores);

  %% Empty range?
  if min_score ~= max_score
    %% Bin size
    bin_size = (max_score - min_score) / histo_bins;

    %% Bin limits
    bin_limits = min_score + bin_size * (0 : (histo_bins - 1));

    %% Plots
    plots = {};

    %% For each cl
    for cl = 1 : k
      %% Elements
      cluster = find(expec(cl, :));
      cl_size = length(cluster);

      %% Bins
      bins = 1 + floor((scores(cluster) - min_score) / bin_size);
      bins(bins == (histo_bins + 1)) = histo_bins;

      %% Histogram
      histo = full(sum(sparse(bins, 1 : cl_size, ones(1, cl_size), ...
			      histo_bins, cl_size), 2));

      %% Add their data
      plots = cell_push(plots, bin_limits, histo, "-");
    endfor

    %% Full bins
    bins = 1 + floor((scores - min_score) / bin_size);
    bins(bins == (histo_bins + 1)) = histo_bins;

    %% Histogram
    histo = full(sum(sparse(bins, 1 : elems, ones(1, elems), ...
			    histo_bins, elems), 2));

    %% Add it
    plots = cell_push(plots, bin_limits, histo, "-", "linewidth", 2);

    %% Plot
    figure(window);
    plot(plots{:});

    %% Stop?
    if pause_time > 0
      pause(pause_time);
    endif
  endif
endfunction


%%%%%%%%%%%%%%%%
%% Clusterers %%
%%%%%%%%%%%%%%%%

%% Kernel
switch cmd_opts.kernel
  case K_LINEAR
    kernel = LinearKernel();
  case K_POLYNOMIAL
    kernel = PolynomialKernel(cmd_opts.poly_degree, cmd_opts.poly_homogeneous);
  case K_RBF
    kernel = RBFKernel(cmd_opts.rbf_gamma);
endswitch

%% Distance
switch cmd_opts.distance
  case D_EUCLIDEAN
    distance = SqEuclideanDistance();
  case D_KERNEL
    distance = KernelDistance(kernel);
  case D_MAHALANOBIS
    distance = MahalanobisDistance(data);
endswitch

%% Clusterer
switch cmd_opts.clusterer
  case C_BERNOULLI
    clusterer = ...
	Bernoulli(struct("em_threshold",  cmd_opts.em_threshold, ...
			 "em_iterations", cmd_opts.em_iterations));
  case C_VORONOI
    clusterer = ...
	Voronoi(distance, struct("soft_alpha", cmd_opts.soft_alpha));
endswitch

%% Ewocs
ewocs = ...
    EWOCS(clusterer, struct("ensemble_size", cmd_opts.ensemble_size, ...
			    "min_clusters",  cmd_opts.min_clusters,  ...
			    "max_clusters",  cmd_opts.max_clusters));
                            %% "interpolator",  ClusterInterpolator()));

%%%%%%%%%%%%%%%
%% Same side %%
%%%%%%%%%%%%%%%

%% Do the same side task
function do_same_side(clusterer, cmd_opts)

  %% Create figures
  if cmd_opts.do_plot
    truth_fig = figure();
    expec_fig = figure();
  endif

  %% Total size, and number of pairs
  all_sizes  = [ cmd_opts.noise_size, cmd_opts.signal_size ];
  total_size = sum(all_sizes);
  pair_sizes = all_sizes' * all_sizes;

  %% Simplified size, and number of pairs
  simp_all_sizes  = [ cmd_opts.noise_size, sum(cmd_opts.signal_size) ];
  simp_pair_sizes = simp_all_sizes' * simp_all_sizes;

  %% Accumulated probs
  acc_prob      = zeros(1 + cmd_opts.signal_groups, 1 + cmd_opts.signal_groups);
  simp_acc_prob = zeros(2, 2);

  %% For each outer run
  for or = 1 : cmd_opts.outer_runs
    %% Generate the data
    [ data, truth ] = gen_data(cmd_opts);

    %% Truth expectation
    t_expec = sparse(truth, 1 : total_size, ones(1, total_size),
		     1 + cmd_opts.signal_groups, total_size);

    %% Simplified expectation
    s_expec = sparse(1 + (truth > 1), 1 : total_size, ones(1, total_size),
		     2, total_size);

    %% Plot?
    if cmd_opts.do_plot
      do_plot_expec(truth_fig, data, t_expec, 0.0);
    endif

    %% For each inner run
    for ir = 1 : cmd_opts.inner_runs
      %% Number of clusters
      k = floor(cmd_opts.min_clusters + (cmd_opts.range_clusters + 1) * rand());

      %% Cluster it
      expec = cluster(clusterer, data, k);

      %% Harden it
      [ max_expec, max_cl ] = max(expec);
      h_expec = sparse(max_cl, 1 : total_size, ones(1, total_size),
		       k, total_size);

      %% Plot?
      if cmd_opts.do_plot
	do_plot_expec(expec_fig, data, h_expec, cmd_opts.pause_time);
      endif

      %% Map
      mapped_expec = t_expec * h_expec';

      %%%% Count co-clustererd pairs
      pairs   = full(mapped_expec * mapped_expec');
      pairs ./= pair_sizes;

      %%%% Add to accumulated probabilities
      acc_prob += pairs;

      %% Simplified map
      simp_mapped_expec = s_expec * h_expec';

      %%%% Count co-clustererd pairs
      simp_pairs   = full(simp_mapped_expec * simp_mapped_expec');
      simp_pairs ./= simp_pair_sizes;

      %%%% Add to accumulated probabilities
      simp_acc_prob += simp_pairs;
    endfor
  endfor

  %% Average results
  acc_prob      ./= cmd_opts.inner_runs * cmd_opts.outer_runs;
  simp_acc_prob ./= cmd_opts.inner_runs * cmd_opts.outer_runs;

  %% Display results
  acc_prob
  simp_acc_prob
endfunction


%%%%%%%%%%%%%%%%%%%%%
%% Score histogram %%
%%%%%%%%%%%%%%%%%%%%%

%% Do the score histogram task
function do_score_histo(ewocs, cmd_opts)

  %% Create figures
  if cmd_opts.do_plot
    truth_fig = figure();
    expec_fig = figure();
  endif
  sorted_fig  = figure();
  t_score_fig = figure();
  s_score_fig = figure();
  roc_fig     = figure();

  %% Total size, and number of pairs
  all_sizes  = [ cmd_opts.noise_size, cmd_opts.signal_size ];
  total_size = sum(all_sizes);
  pair_sizes = all_sizes' * all_sizes;

  %% For each outer run
  for or = 1 : cmd_opts.outer_runs
    %% Generate the data
    [ data, truth ] = gen_data(cmd_opts);

    %% Truth expectation
    t_expec = sparse(truth, 1 : total_size, ones(1, total_size),
		     1 + cmd_opts.signal_groups, total_size);

    %% Simplified expectation
    s_expec = sparse(1 + (truth > 1), 1 : total_size, ones(1, total_size),
		     2, total_size);

    %% Plot?
    if cmd_opts.do_plot
      do_plot_expec(truth_fig, data, t_expec, 0.0);
    endif

    %% For each inner run
    for ir = 1 : cmd_opts.inner_runs
      %% Run ewocs
      [ expec, model, info, scores ] = cluster(ewocs, data);

      %% Harden it
      h_expec = sparse(1 + (expec > 0.5), 1 : total_size, ones(1, total_size),
		       2, total_size);

      %% Plot?
      if cmd_opts.do_plot
	do_plot_expec(expec_fig, data, h_expec, 0.0);
      endif

      %% Plot score
      do_plot_sorted_score(sorted_fig, scores, 0.0);
      do_plot_score(t_score_fig, scores, t_expec, ...
		    cmd_opts.histo_bins, 0.0);
      do_plot_score(s_score_fig, scores, s_expec, ...
		    cmd_opts.histo_bins, cmd_opts.pause_time);
    endfor
  endfor
endfunction


%%%%%%%%%%%%
%% Do it! %%
%%%%%%%%%%%%

%% According to the task
switch cmd_opts.task
  case T_SAME_SIDE
    do_same_side(clusterer, cmd_opts)

  case T_SCORE_HISTO
    do_score_histo(ewocs, cmd_opts)
endswitch
