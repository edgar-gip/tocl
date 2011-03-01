%% -*- mode: octave; -*-

%% Find RBFKernel Bregman Clustering optimal parameters

%% Author: Edgar Gonz�lez i Pellicer


%% Octopus
pkg load octopus

%% Extra path
addpath(binrel("private"));


%%%%%%%%%%%%%%
%% Clusters %%
%%%%%%%%%%%%%%

%% Number of clusters
function [ k ] = determine_clusters(data, truth, opts)
  switch opts.clusters
    case "sqrt"
      k = max([ 2, floor(sqrt(size(data, 2))) ]);

    case "true"
      k = max(truth);

    otherwise
      k = opts.clusters;
  endswitch
endfunction


%%%%%%%%%%%
%% Range %%
%%%%%%%%%%%

%% Distance range
function [ sqe_min, sqe_max ] = sqe_range(data, subsample)
  %% Size
  n_data = size(data, 2);

  %% Subsample?
  if isempty(subsample) || n_data <= subsample
    %% Just find it
    sqe   = apply(SqEuclideanDistance(), data);
    msize = n_data;

  else
    %% Take some indices
    idxs = randperm(n_data)(1 : subsample);

    %% Find those distances only
    sqe   = apply(SqEuclideanDistance(), data(:, idxs));
    msize = subsample;
  endif

  %% Range
  sqe_min = min(min(sqe + inf * eye(msize)));
  sqe_max = max(max(sqe));
endfunction


%%%%%%%%%%%%
%% Bounds %%
%%%%%%%%%%%%

%% Minimum alpha value
%% \min \alpha s.t.
%% \frac{e^{-\alpha d_{min}}}
%%      {e^{-\alpha d_{min}} + (k - 1) e^{-\alpha d_{max}}} >
%% \frac{1}{k} + \epsilon
function [ alpha_min ] = minimum_alpha(d_min, d_max, k, epsilon)
  %% Delta
  %% \delta = \frac{1}{k} + \epsilon
  delta = 1 / k + epsilon;

  %% \alpha > \frac{\log \frac{(k - 1) \delta}{1 - \delta}}{d_{max} - d_{min}}
  alpha_min = log((k - 1) * delta / (1 - delta)) / (d_max - d_min);
endfunction

%% Maximum gamma value
%% \max \gamma s.t.
%% 2 (1 - e^{-\gamma d_{min}}) < 2 - \epsilon
function [ gamma_max ] = maximum_gamma(d_min, epsilon)
  %% \gamma < - \frac{\log \frac{\epsilon}{2}}{d_{min}}
  gamma_max = - log(epsilon / 2) / d_min;
endfunction

%% Minimum gamma value
%% \max \gamma s.t.
%% 2 (1 - e^{-\gamma d_{max}}) > \epsilon
function [ gamma_min ] = minimum_gamma(d_max, epsilon)
  %% \gamma < - \frac{\log (1 - \frac{\epsilon}{2})}{d_{max}}
  gamma_min = - log(1 - epsilon / 2) / d_max;
endfunction


%%%%%%%%%%%%%%%%%%%%%%%
%% Centroid distance %%
%%%%%%%%%%%%%%%%%%%%%%%

%% Minimum centroid distance
function [ dist_min ] = ...
      minimum_centroid_distance(alpha, gamma, data, k, opts, in_pp = false)
  %% Clusterer
  %% (Yes, alpha is beta)
  clusterer = BregmanEM(KernelDistance(RBFKernel(gamma)), ...
			struct("beta", alpha));

  %% Accumulate
  dist_mins = zeros(1, opts.repeats);

  %% Log
  if opts.verbose
    fprintf(2, "f(%12g, %12g) = m(", alpha, gamma);
  endif

  %% Do it again, Sam
  for r = 1 : opts.repeats
    %% Cluster
    [ expec, model ] = cluster(clusterer, data, k);

    %% Centroids
    cs = centroids(model);

    %% Distance
    dists        = apply(SqEuclideanDistance(), cs) + inf * eye(k);
    dist_mins(r) = min(min(dists));

    %% Log
    if opts.verbose
      fprintf(2, " %12g", dist_mins(r));
    endif
  endfor

  %% Median
  dist_min = median(dist_mins);

  %% Log
  if opts.verbose
    if dist_min < opts.epsilon_down
      fprintf(2, " ) = %12g (Down)\n", dist_min);
    elseif dist_min > opts.epsilon_up
      fprintf(2, " ) = %12g (Up)\n", dist_min);
    else
      fprintf(2, " ) = %12g (Mid)\n", dist_min);
    endif
  endif

  %% Plot
  if ~in_pp && opts.pp
    plot_point(alpha, gamma, dist_min, opts)
  endif
endfunction


%%%%%%%%%%%%%%
%% Pre-plot %%
%%%%%%%%%%%%%%

%% Make the plot
function make_plot(alpha, gamma, mcd, opts)
  %% Figure
  figure("name", "MCD");

  %% Plot
  if opts.pp_contour
    contour(alpha, gamma, mcd);
  else
    mesh(alpha, gamma, mcd);
  endif

  %% Log-plots
  set(gca(), "xscale", "log");
  set(gca(), "yscale", "log");

  %% Labels
  xlabel("alpha");
  ylabel("gamma");

  %% Hold on
  hold("on");

  %% Update
  replot();
endfunction

%% Plot a point
function plot_point(alpha0, gamma0, mcd0, opts)
  %% Inside the range?
  if opts.pp_min_alpha <= alpha0 && ...
     alpha0 <= opts.pp_max_alpha && ...
     opts.pp_min_gamma <= gamma0 && ...
     gamma0 <= opts.pp_max_gamma

    %% Colour
    if mcd0 < opts.epsilon_down
      colour = "r*";
    elseif mcd0 > opts.epsilon_up
      colour = "g*";
    else
      colour = "y*";
    endif

    %% Plot
    if opts.pp_contour
      plot(alpha0, gamma0, colour);
    else
      plot3(alpha0, gamma0, mcd0, colour);
    endif

    %% Update
    replot();
  endif
endfunction

%% Pre-plot
function pre_plot(data, k, opts)
  %% Change repeats
  opts.repeats = opts.pp_repeats;

  %% Alpha values
  alpha = log_series(opts.pp_min_alpha, opts.pp_max_alpha, opts.pp_n_alpha);
  gamma = log_series(opts.pp_min_gamma, opts.pp_max_gamma, opts.pp_n_gamma);

  %% Output
  centroid_distance = zeros(opts.pp_n_gamma, opts.pp_n_alpha);

  %% For each one
  for i = 1 : opts.pp_n_alpha
    for j = 1 : opts.pp_n_gamma
      %% Value
      mcd = ...
	  minimum_centroid_distance(alpha(i), gamma(j), data, k, opts, true());

      %% Store it
      centroid_distance(j, i) = mcd;
    endfor
  endfor

  %% Make the plot
  make_plot(alpha, gamma, centroid_distance, opts);
endfunction


%%%%%%%%%%%%
%% Search %%
%%%%%%%%%%%%

%% Alpha binary search
%% f(alpha_low)  < e
%% f(alpha_high) > e
function [ log_alpha ] = ...
      alpha_binary_search(log_alpha_low, log_alpha_high, log_gamma, ...
			  data, k, opts)
  %% Gamma
  gamma = exp(log_gamma);

  %% Log
  fprintf(2, "\n");
  fprintf(2, "bin_search: alpha in [ %12g .. %12g ], gamma = %12g\n",
	  exp(log_alpha_low), exp(log_alpha_high), gamma);

  %% Loop
  while log_alpha_high - log_alpha_low > opts.precision
    %% Mid
    log_alpha_mid = (log_alpha_high + log_alpha_low) / 2;
    alpha         = exp(log_alpha_mid);

    %% Value
    mcd = minimum_centroid_distance(alpha, gamma, data, k, opts);

    %% Where is my point?
    if mcd < opts.epsilon_down
      %% Too low
      log_alpha_low  = log_alpha_mid;

    elseif mcd > opts.epsilon_up
      %% Too high
      log_alpha_high = log_alpha_mid;

    else
      %% There, there
      break;
    endif
  endwhile

  %% Return
  log_alpha = (log_alpha_high + log_alpha_low) / 2;
endfunction

%% Alpha lemming search
function [ log_alpha ] = ...
      alpha_lemming_search(log_alpha, log_gamma, data, k, opts)
  %% Gamma
  gamma = exp(log_gamma);

  %% Log
  fprintf(2, "\n");
  fprintf(2, "lemming_search: alpha in [ %12g .. %12g ], gamma = %12g\n",
	  exp(log_alpha), inf, gamma);

  %% Loop
  mcd = 0.0;
  while mcd < opts.epsilon_down
    %% Add one step
    log_alpha += opts.lemming;
    alpha      = exp(log_alpha);

    %% Find the value
    mcd = minimum_centroid_distance(alpha, gamma, data, k, opts);
  endwhile

  %% More than epsilon_up?
  %% Otherwise, we are already there
  if mcd > opts.epsilon_up
    %% Binary search
    log_alpha = alpha_binary_search(log_alpha - opts.lemming, ...
				    log_alpha, log_gamma, data, k, opts);
  endif
endfunction

%% Gamma binary search
%% f(gamma_low)  < e
%% f(gamma_high) > e
function [ log_gamma ] = ...
      gamma_binary_search(log_alpha, log_gamma_low, log_gamma_high, ...
			  data, k, opts)
  %% Alpha
  alpha = exp(log_alpha);

  %% Log
  fprintf(2, "\n");
  fprintf(2, "bin_search: alpha = %12g, gamma in [ %12g .. %12g ]\n",
	  alpha, exp(log_gamma_low), exp(log_gamma_high));

  %% Loop
  while log_gamma_high - log_gamma_low > opts.precision
    %% Mid
    log_gamma_mid = (log_gamma_high + log_gamma_low) / 2;
    gamma         = exp(log_gamma_mid);

    %% Value
    mcd = minimum_centroid_distance(alpha, gamma, data, k, opts);

    %% Where is my point?
    if mcd < opts.epsilon_down
      %% Too low
      log_gamma_low  = log_gamma_mid;

    elseif mcd > opts.epsilon_up
      %% Too high
      log_gamma_high = log_gamma_mid;

    else
      %% There, there
      break;
    endif
  endwhile

  %% Return
  log_gamma = (log_gamma_high + log_gamma_low) / 2;
endfunction

%% Gamma binary reverse
%% f(alpha_low)  > e
%% f(alpha_high) < e
function [ log_gamma ] = ...
      gamma_binary_reverse(log_alpha, log_gamma_low, log_gamma_high, ...
			   data, k, opts)
  %% Alpha
  alpha = exp(log_alpha);

  %% Log
  fprintf(2, "\n");
  fprintf(2, "bin_search: alpha = %12g, gamma in [ %12g .. %12g ]\n",
	  alpha, exp(log_gamma_low), exp(log_gamma_high));

  %% Loop
  while log_gamma_high - log_gamma_low > opts.precision
    %% Mid
    log_gamma_mid = (log_gamma_high + log_gamma_low) / 2;
    gamma         = exp(log_gamma_mid);

    %% Value
    mcd = minimum_centroid_distance(alpha, gamma, data, k, opts);

    %% Where is my point?
    if mcd < opts.epsilon_down
      %% Too high
      log_gamma_high  = log_gamma_mid;

    elseif mcd > opts.epsilon_up
      %% Too low
      log_gamma_low = log_gamma_mid;

    else
      %% There, there
      break;
    endif
  endwhile

  %% Return
  log_gamma = (log_gamma_high + log_gamma_low) / 2;
endfunction

%% Gamma cow search
function [ log_gamma_min, log_gamma_max ] = ...
      gamma_cow_search(log_alpha, log_gamma_min, log_gamma, log_gamma_max, ...
		       data, k, opts)
  %% Alpha
  alpha = exp(log_alpha);

  %% Gamma ranges
  log_gamma_to_min_range = log_gamma - log_gamma_min;
  log_gamma_to_max_range = log_gamma_max - log_gamma;

  %% Side where we found something
  side = 0;

  %% Maximum j
  max_j = min([ opts.max_denom, ...
	       ceil(max([ log_gamma_to_min_range, ...
			 log_gamma_to_max_range ]) / ...
		    opts.precision) ]);

  %% Log
  fprintf(2, "\n");
  fprintf(2, "cow_search: alpha = %12g, gamma in [ %12g .. %12g .. %12g ]\n",
	  alpha, exp(log_gamma_min), exp(log_gamma), exp(log_gamma_max));
  fprintf(2, "* max_denom = %d\n", max_j);

  %% Farey series

  %% Outer loop
  j = 2;
  while side == 0 && j < max_j
    %% Inner loop
    i = 1;
    while side == 0 && i < j
      %% Co-prime
      if gcd(i, j) == 1
	%% Log
	fprintf(2, "* %d / %d\n", i, j);

	%% Between current and min

	%% Gamma
	log_gamma_mid = log_gamma - i / j * log_gamma_to_min_range;

	%% Find the value
	mcd = minimum_centroid_distance(alpha, exp(log_gamma_mid), ...
					data, k, opts);

	%% Non-zero
	if mcd > opts.epsilon_up
	  %% Found!
	  found = true;
	  side  = -1;

	else
	  %% Between max and current

	  %% Gamma
	  log_gamma_mid = log_gamma + i / j * log_gamma_to_max_range;

	  %% Find the value
	  mcd = minimum_centroid_distance(alpha, exp(log_gamma_mid), ...
					  data, k, opts);

	  %% Non-zero
	  if mcd > opts.epsilon_up
	    %% Found!
	    found = true;
	    side  = +1;
	  endif
	endif
      endif

      %% Next
      i += 1;
    endwhile

    %% Next
    j += 1;
  endwhile

  %% Which side
  if side == -1
    %% Binary search
    log_gamma_min = ...
	gamma_binary_search(log_alpha, log_gamma_min, log_gamma_mid, ...
			    data, k, opts);
    log_gamma_max = log_gamma;

  elseif side == +1
    %% Binary search
    log_gamma_min = log_gamma;
    log_gamma_max = ...
	gamma_binary_reverse(log_alpha, log_gamma_mid, log_gamma_max, ...
			     data, k, opts);

  else %% Already there!
    %% Done
    log_gamma_min = log_gamma_max = log_gamma;
  endif
endfunction

%% Main search procedure
function [ opt_alpha, opt_gamma ] = find_alpha_gamma(data, k, opts);
  %% Size
  [ n_dims, n_data ] = size(data);

  %% Distances
  [ sqe_min, sqe_max ] = sqe_range(data, opts.subsample);

  %% Debug
  fprintf(2, "sqe   in [ %12g .. %12g ]\n", sqe_min, sqe_max);

  %% Bounds
  alpha_min = minimum_alpha(0, 2, k, opts.epsilon_dist);
  gamma_min = minimum_gamma(sqe_max, opts.epsilon_dist);
  gamma_max = maximum_gamma(sqe_min, opts.epsilon_dist);

  %% Debug
  fprintf(2, "alpha in [ %12g .. %12g ]\n", alpha_min, inf);
  fprintf(2, "gamma in [ %12g .. %12g ]\n", gamma_min, gamma_max);

  %% Starting alpha and gamma (in log form)
  log_alpha_min =  log(alpha_min);
  log_alpha     =  log_alpha_min;
  log_gamma_min =  log(gamma_min);
  log_gamma_max =  log(gamma_max);
  log_gamma     = (log_gamma_min + log_gamma_max) / 2;

  %% Start by lemming search
  log_alpha = alpha_lemming_search(log_alpha, log_gamma, data, k, opts);

  %% Gamma search
  [ log_gamma_min, log_gamma_max ] = ...
      gamma_cow_search(log_alpha, log_gamma_min, log_gamma, log_gamma_max, ...
		       data, k, opts);

  %% Whitin the range?
  while log_gamma_max - log_gamma_min > opts.precision
    %% Debug
    fprintf(2, "\n");
    fprintf(2, "alpha in [ %12g .. %12g ]\n", alpha_min, exp(log_alpha));
    fprintf(2, "gamma in [ %12g .. %12g ]\n", ...
	    exp(log_gamma_min), exp(log_gamma_max));

    %% Middle gamma
    log_gamma = (log_gamma_min + log_gamma_max) / 2;

    %% Alpha binary search
    log_alpha = alpha_binary_search(log_alpha_min, log_alpha, log_gamma, ...
				    data, k, opts);

    %% Gamma search
    [ log_gamma_min, log_gamma_max ] = ...
	gamma_cow_search(log_alpha, log_gamma_min, log_gamma, log_gamma_max, ...
			 data, k, opts);
  endwhile

  %% Last alpha binary search
  %% log_alpha = alpha_binary_search(log_alpha_min, log_alpha, log_gamma, ...
  %%                                 data, k, opts);

  %% Output
  opt_alpha = exp(log_alpha);
  opt_gamma = exp((log_gamma_min + log_gamma_max) / 2);
endfunction


%%%%%%%%%%
%% Main %%
%%%%%%%%%%

%% Default options
def_opts              = struct();
def_opts.clusters     = "sqrt";
def_opts.epsilon_dist = 1e-10;
def_opts.epsilon_down = 1e-4;
def_opts.epsilon_up   = 1e-3;
def_opts.lemming      = 2;
def_opts.max_denom    = 10;
def_opts.precision    = 0.1;
def_opts.repeats      = 5;
def_opts.subsample    = [];
def_opts.verbose      = false();

%% Pre-plot opts
def_opts.pp           = false();
def_opts.pp_contour   = false();
def_opts.pp_repeats   = 1;
def_opts.pp_min_alpha =   0.01;
def_opts.pp_max_alpha = 100.0;
def_opts.pp_n_alpha   = 21;
def_opts.pp_min_gamma =   0.01;
def_opts.pp_max_gamma = 100.0;
def_opts.pp_n_gamma   = 21;

%% Helper functions
function [ opts ] = sqrt_clusters(opts, value)
  opts.clusters = "sqrt";
endfunction
function [ opts ] = true_clusters(opts, value)
  opts.clusters = "true";
endfunction
function [ opts ] = no_subsample(opts, value)
  opts.subsample = [];
endfunction

%% Parse options
[ args, opts ] = ...
    get_options(def_opts, ...
		"sqrt-clusters",  @sqrt_clusters, ...
		"true-clusters",  @true_clusters, ...
		"clusters=i",     "clusters",     ...
		"contour!",       "contour",      ...
		"epsilon-dist=f", "epsilon_dist", ...
		"epsilon-down=f", "epsilon_down", ...
		"epsilon-up=f",   "epsilon_up",   ...
		"lemming=f",      "lemming",      ...
		"max-denom=i",    "max_denom",    ...
		"precision=f",    "precision",    ...
		"repeats=i",      "repeats",      ...
		"subsample=i",    "subsample",    ...
		"no-subsample",   @no_subsample,  ...
		"verbose!",       "verbose",      ...
		...
		"pp!",            "pp",           ...
		"pp-contour!",    "pp_contour",   ...
		"pp-min-alpha=f", "pp_min_alpha", ...
		"pp-max-alpha=f", "pp_max_alpha", ...
		"pp-n-alpha=i",   "pp_n_alpha",   ...
		"pp-min-gamma=f", "pp_min_gamma", ...
		"pp-max-gamma=f", "pp_max_gamma", ...
		"pp-n-gamma=i",   "pp_n_gamma");

%% Arguments
if length(args) ~= 2
  error("Wrong number of arguments: Expected [options] <input> <seed>");
endif

%% Input file
input = args{1};
try
  load(input, "data", "truth");
catch
  error("Cannot load data from '%s': %s", input, lasterr());
end_try_catch

%% Seed
seed = parse_double(args{2}, "seed");

%% Initialize seed
set_all_seeds(seed);

%% Number of clusters
k = determine_clusters(data, truth, opts);

%% Debug
fprintf(2, "k = %d\n\n", k);

%% Pre-plot?
if opts.pp
  pre_plot(data, k, opts);
endif

%% Find them
[ opt_alpha, opt_gamma ] = find_alpha_gamma(data, k, opts);

%% Display them
printf("alpha = %12g\ngamma = %12g\n", opt_alpha, opt_gamma);

%% Pause
pause();
