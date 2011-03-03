%% -*- mode: octave; -*-

%% Find RBFKernel Bregman Clustering optimal parameters

%% Author: Edgar Gonz�lez i Pellicer


%% Octopus
pkg load octopus

%% Extra path
addpath(binrel("private"));

%% Clusterer types
enum BREGMAN SOFT_BBC


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


%%%%%%%%%%
%% Plot %%
%%%%%%%%%%

%% Create the figure
function create_figure(opts)
  %% Figure
  figure("name", "MCD");

  %% Clear
  plot([ opts.min_alpha, opts.min_alpha, opts.max_alpha, opts.max_alpha ], ...
       [ opts.min_gamma, opts.max_gamma, opts.max_gamma, opts.min_gamma ], ...
       "6*", "linewidth", 4);

  %% Log-plots
  set(gca(), "xscale", "log");
  set(gca(), "yscale", "log");

  %% Labels
  xlabel("alpha");
  ylabel("gamma");

  %% Hold
  hold("on");

  %% Update
  replot();
endfunction

%% Plot grid
function plot_grid(alpha, gamma, mcd, opts)
  %% Plot
  if opts.p_contour
    contour(alpha, gamma, mcd);
  else
    mesh(alpha, gamma, mcd);
  endif

  %% Update
  replot();
endfunction

%% Plot curve
function plot_curve(curve, mcd, big, opts)
  %% Big?
  if opts.p_contour
    if big
      plot(curve(1, :), curve(2, :), "-", "linewidth", 2);
    else
      plot(curve(1, :), curve(2, :), "-");
    endif
  else
    if big
      plot3(curve(1, :), curve(2, :), mcd, "-", "linewidth", 2);
    else
      plot3(curve(1, :), curve(2, :), mcd, "-");
    endif
  endif

  %% Update
  replot();
endfunction

%% Plot a point
function plot_point(alpha0, gamma0, mcd0, big, opts)
  %% Big or inside the range?
  if big || ...
	(opts.min_alpha <= alpha0 && alpha0 <= opts.max_alpha && ...
	 opts.min_gamma <= gamma0 && gamma0 <= opts.max_gamma)

    %% Colour
    if mcd0 < opts.epsilon_down
      colour = "r*";
    elseif mcd0 > opts.epsilon_up
      colour = "g*";
    else
      colour = "y*";
    endif

    %% Plot
    if opts.p_contour
      if big
	plot(alpha0, gamma0, colour, "linewidth", 8);
      else
	plot(alpha0, gamma0, colour);
      endif
    else
      if big
	plot3(alpha0, gamma0, mcd0, colour, "linewidth", 8);
      else
	plot3(alpha0, gamma0, mcd0, colour);
      endif
    endif

    %% Update
    replot();
  endif
endfunction


%%%%%%%%%%%%%%%%%%%%%%%
%% Centroid distance %%
%%%%%%%%%%%%%%%%%%%%%%%

%% Minimum centroid distance
function [ dist_min ] = ...
      minimum_centroid_distance(alpha, gamma, data, k, repeats, do_plot, opts)

  %% Clusterer
  %% (Yes, alpha is beta)
  switch opts.clusterer
    case BREGMAN
      clusterer = BregmanEM(KernelDistance(RBFKernel(gamma)), ...
			    struct("beta", alpha));

    case SOFT_BBC
      clusterer = SeqEM({ KMeans(KernelDistance(RBFKernel(gamma))),
			  SoftBBCEM(KernelDistance(RBFKernel(gamma)), ...
				    struct("beta", alpha)) });
  endswitch

  %% Accumulate
  dist_mins = zeros(1, repeats);

  %% Log
  if opts.verbose
    fprintf(2, "f(%12g, %12g) = m(", alpha, gamma);
  endif

  %% Do it again, Sam
  for r = 1 : repeats
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
  if do_plot
    plot_point(alpha, gamma, dist_min, false(), opts)
  endif
endfunction


%%%%%%%%%%%%
%% Output %%
%%%%%%%%%%%%

%% Result
function result(label, alpha, gamma, run, opts)
  %% Display the label and the values
  printf("%10s: alpha = %12g gamma = %12g\n", label, alpha, gamma);

  %% Run?
  if ~isnan(alpha) && run
    %% Command string
    cmd = sprintf(cstrcat("octave -q scoreAndoData.m %s rbf %g", ...
			  " ewocs_voro %g,%d,%d 1 %d"),          ...
		  opts.input, gamma, alpha, opts.run_repeats, ...
		  opts.run_clusters, opts.seed);

    %% Display it
    fprintf(2, "\n%s: %s\n", label, cmd);

    %% Run it
    system(cmd);
  endif
endfunction


%%%%%%%%%%%%
%% Manual %%
%%%%%%%%%%%%

%% Manual
function do_manual(data, k, opts)
  %% Value
  mcd = ...
      minimum_centroid_distance(opts.man_alpha, opts.man_gamma, ...
				data, k, 1, opts.plot, opts);

  %% Plot
  if opts.plot
    plot_point(opts.man_alpha, opts.man_gamma, mcd, true(), opts);
  endif

  %% Result
  result("Manual", opts.man_alpha, opts.man_gamma, opts.man_run, opts);
endfunction


%%%%%%%%%%%%%%%%%
%% Grid search %%
%%%%%%%%%%%%%%%%%

%% Left-most search
function [ lm_alpha, lm_gamma, th_mcd, th_curve ] = ...
      leftmost_search(alpha, gamma, mcd, opts)

  %% Max
  max_mcd = max(max(mcd));
  th_mcd  = max_mcd * opts.max_fraction;

  %% Find contour level
  [ th_curve ] = contourc(alpha, gamma, mcd, [ th_mcd, th_mcd ]);

  %% Empty?
  if isempty(th_curve)
    %% All empty
    lm_alpha = lm_gamma = lm_mcd = [];

  else
    %% Remove contour info
    th_curve = th_curve(:, 2 : size(th_curve, 2));

    %% Left-most alpha
    lm_alpha = min(th_curve(1, :));

    %% Average gamma
    lm_gamma = mean(th_curve(2, th_curve(1, :) == lm_alpha));
  endif
endfunction


%% Do the grid
function do_grid(data, k, opts)
  %% Log
  fprintf(2, "\npp: alpha in [ %8g .. %8g ], gamma in [ %8g .. %8g ]\n", ...
	  opts.min_alpha, opts.max_alpha, opts.min_gamma, ...
	  opts.max_gamma);

  %% Alpha values
  alpha = log_series(opts.min_alpha, opts.max_alpha, opts.g_n_alpha);
  gamma = log_series(opts.min_gamma, opts.max_gamma, opts.g_n_gamma);

  %% Output
  centroid_distance = zeros(opts.g_n_gamma, opts.g_n_alpha);

  %% For each one
  for i = 1 : opts.g_n_alpha
    for j = 1 : opts.g_n_gamma
      %% Value
      mcd = ...
	  minimum_centroid_distance(alpha(i), gamma(j), data, k, ...
				    opts.g_repeats, false(), opts);

      %% Store it
      centroid_distance(j, i) = mcd;
    endfor
  endfor

  %% Plot
  if opts.plot
    %% Plot the grid
    plot_grid(alpha, gamma, centroid_distance, opts);

    %% Find contour level
    [ th_curve ] = contourc(alpha, gamma, centroid_distance, ...
			    [ opts.epsilon_up, opts.epsilon_up ]);

    %% Empty?
    if ~isempty(th_curve)
      %% Remove contour info
      th_curve = th_curve(:, 2 : size(th_curve, 2))

      %% Plot
      plot_curve(th_curve, opts.epsilon_up, true(), opts);
    endif
  endif

  %% Detect
  [ lm_alpha, lm_gamma, th_mcd, th_curve ] = ...
      leftmost_search(alpha, gamma, centroid_distance, opts);

  %% Plot
  if isempty(lm_alpha)
    %% Empty result
    result("Grid", nan, nan, false(), opts);

  else
    %% Plot
    if opts.plot
      plot_curve(th_curve, th_mcd, true(), opts);
      plot_point(lm_alpha, lm_gamma, th_mcd, true(), opts);
    endif

    %% Result
    result("Grid", lm_alpha, lm_gamma, opts.g_run, opts);
  endif
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
  while log_alpha_high - log_alpha_low > opts.s_precision
    %% Mid
    log_alpha_mid = (log_alpha_high + log_alpha_low) / 2;
    alpha         = exp(log_alpha_mid);

    %% Value
    mcd = minimum_centroid_distance(alpha, gamma, data, k, opts.s_repeats, ...
				    opts.plot, opts);

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
    log_alpha += opts.s_lemming;
    alpha      = exp(log_alpha);

    %% Find the value
    mcd = minimum_centroid_distance(alpha, gamma, data, k, opts.s_repeats, ...
				    opts.plot, opts);
  endwhile

  %% More than epsilon_up?
  %% Otherwise, we are already there
  if mcd > opts.epsilon_up
    %% Binary search
    log_alpha = alpha_binary_search(log_alpha - opts.s_lemming, ...
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
  while log_gamma_high - log_gamma_low > opts.s_precision
    %% Mid
    log_gamma_mid = (log_gamma_high + log_gamma_low) / 2;
    gamma         = exp(log_gamma_mid);

    %% Value
    mcd = minimum_centroid_distance(alpha, gamma, data, k, opts.s_repeats, ...
				    opts.plot, opts);

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


%% Gamma binary reverse search
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
  while log_gamma_high - log_gamma_low > opts.s_precision
    %% Mid
    log_gamma_mid = (log_gamma_high + log_gamma_low) / 2;
    gamma         = exp(log_gamma_mid);

    %% Value
    mcd = minimum_centroid_distance(alpha, gamma, data, k, opts.s_repeats, ...
				    opts.plot, opts);

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
  max_j = min([ opts.s_max_denom, ...
	       ceil(max([ log_gamma_to_min_range, ...
			 log_gamma_to_max_range ]) / ...
		    opts.s_precision) ]);

  %% Log
  fprintf(2, "\n");
  fprintf(2, "cow_search: alpha = %12g, gamma in [ %12g .. %12g .. %12g ]\n",
	  alpha, exp(log_gamma_min), exp(log_gamma), exp(log_gamma_max));
  fprintf(2, "* max_denom = %d\n", max_j);

  %% Limits
  to_min_limit = 1.0;
  to_max_limit = 1.0;

  %% Farey series

  %% Outer loop
  j = 2;
  while side == 0 && j < max_j
    %% Inner loop
    i = 1;
    while side == 0 && i < j
      %% Fraktion
      frak = i / j;

      %% Beyond both limits?
      if frak >= to_min_limit && frak >= to_max_limit
	break;
      endif

      %% Co-prime
      if gcd(i, j) == 1
	%% Log
	fprintf(2, "* %d / %d\n", i, j);

	%% Between min and current, and within the limit?
	if frak < to_min_limit
	  %% Gamma
	  log_gamma_mid = log_gamma - frak * log_gamma_to_min_range;

	  %% Find the value
	  mcd = minimum_centroid_distance(alpha, exp(log_gamma_mid), data, ...
					  k, opts.s_repeats, opts.plot, opts);

	  %% Non-zero
	  if mcd > opts.epsilon_up
	    %% Found!
	    side = -1;

	  elseif mcd < opts.epsilon_down
	    %% Limit!
	    to_min_limit = frak;
	  endif
	endif

	%% Not found, between max and current, and within the limit?
	if side == 0 && frak < to_max_limit
	  %% Gamma
	  log_gamma_mid = log_gamma + frak * log_gamma_to_max_range;

	  %% Find the value
	  mcd = minimum_centroid_distance(alpha, exp(log_gamma_mid), data, ...
					  k, opts.s_repeats, opts.plot, opts);

	  %% Non-zero
	  if mcd > opts.epsilon_up
	    %% Found!
	    side = +1;

	  elseif mcd < opts.epsilon_down
	    %% Limit!
	    to_max_limit = frak;
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


%% Alpha mouse binary search
%% f(alpha_low)  < th
%% f(alpha_high) > th
function [ log_alpha, mcd ] = ...
      alpha_mouse_binary_search(log_alpha_low, log_alpha_high, log_gamma, ...
				th, data, k, opts)
  %% Gamma
  gamma = exp(log_gamma);

  %% Log
  fprintf(2, "\n");
  fprintf(2, "bin_search: alpha in [ %12g .. %12g ], gamma = %12g\n",
	  exp(log_alpha_low), exp(log_alpha_high), gamma);

  %% Loop
  while log_alpha_high - log_alpha_low > opts.s_precision
    %% Mid
    log_alpha_mid = (log_alpha_high + log_alpha_low) / 2;
    alpha         = exp(log_alpha_mid);

    %% Value
    mcd = minimum_centroid_distance(alpha, gamma, data, k, opts.s_repeats, ...
				    opts.plot, opts);

    %% Where is my point?
    if mcd < th
      %% Too low
      log_alpha_low  = log_alpha_mid;

    else %% mcd >= th
      %% Too high
      log_alpha_high = log_alpha_mid;
    endif
  endwhile

  %% Return
  log_alpha = (log_alpha_high + log_alpha_low) / 2;
endfunction


%% Alpha mouse search
function [ log_alpha, mcd ] = ...
      alpha_mouse_search(log_alpha, log_gamma, data, k, opts)
  %% Gamma
  gamma = exp(log_gamma);

  %% Log
  fprintf(2, "\n");
  fprintf(2, "mouse_search: alpha in [ %12g .. %12g ], gamma = %12g\n",
	  exp(log_alpha), inf, gamma);

  %% Maximum  mcd
  max_mcd       = opts.epsilon_down;
  max_log_alpha = nan;

  %% Mouse log_alpha
  mouse_log_alpha = log_alpha;

  %% Loop
  stay = 0;
  while stay < opts.s_mouse_stay
    %% Add one step
    mouse_log_alpha += opts.s_mouse;
    alpha            = exp(mouse_log_alpha);

    %% Find the value
    mcd = minimum_centroid_distance(alpha, gamma, data, k, opts.s_repeats, ...
				    opts.plot, opts);

    %% What?
    if mcd > max_mcd
      %% Improvement

      %% Smaller? -> Stay
      if (mcd - max_mcd) / max_mcd < opts.s_mouse_change
	stay += 1;
      endif

      %% Update
      max_mcd       = mcd;
      max_log_alpha = mouse_log_alpha;

    elseif mcd >= opts.epsilon_down
      %% Fall below -> Stay
      stay += 1;
    endif
  endwhile

  %% Binary search
  [ log_alpha, mcd ] = ...
      alpha_mouse_binary_search(log_alpha, max_log_alpha, log_gamma, ...
				opts.max_fraction * max_mcd, data, k, opts);
endfunction


%% Main search procedure
function do_search(data, k, opts);
  %% Size
  [ n_dims, n_data ] = size(data);

  %% Distances
  [ sqe_min, sqe_max ] = sqe_range(data, opts.s_subsample);

  %% Debug
  fprintf(2, "\nsqe   in [ %12g .. %12g ]\n", sqe_min, sqe_max);

  %% Bounds
  alpha_min = minimum_alpha(0, 2, k, opts.s_epsilon_dist);
  gamma_min = minimum_gamma(sqe_max, opts.s_epsilon_dist);
  gamma_max = maximum_gamma(sqe_min, opts.s_epsilon_dist);

  %% Debug
  fprintf(2, "alpha in [ %12g .. %12g ]\n", alpha_min, inf);
  fprintf(2, "gamma in [ %12g .. %12g ]\n", gamma_min, gamma_max);

  %% Starting alpha and gamma (in log form)
  log_alpha_min = log(alpha_min);
  log_alpha     = log_alpha_min;
  log_gamma_min = log(gamma_min);
  log_gamma_max = log(gamma_max);

  %% Heuristic start
  log_gamma = 0.25 * log_gamma_min + 0.75 * log_gamma_max;

  %% Start by lemming search
  log_alpha = alpha_lemming_search(log_alpha, log_gamma, data, k, opts);

  %% Gamma search
  [ log_gamma_min, log_gamma_max ] = ...
      gamma_cow_search(log_alpha, log_gamma_min, log_gamma, log_gamma_max, ...
		       data, k, opts);

  %% Whitin the range?
  while log_gamma_max - log_gamma_min > opts.s_precision
    %% Debug
    fprintf(2, "\n");
    fprintf(2, "alpha in [ %12g .. %12g ]\n", alpha_min, exp(log_alpha));
    fprintf(2, "gamma in [ %12g .. %12g ]\n", ...
	    exp(log_gamma_min), exp(log_gamma_max));

    %% Middle gamma
    log_gamma = 0.25 * log_gamma_min + 0.75 * log_gamma_max;

    %% Alpha binary search
    log_alpha = alpha_binary_search(log_alpha_min, log_alpha, log_gamma, ...
				    data, k, opts);

    %% Gamma search
    [ log_gamma_min, log_gamma_max ] = ...
	gamma_cow_search(log_alpha, log_gamma_min, log_gamma, log_gamma_max, ...
			 data, k, opts);
  endwhile

  %% Last alpha binary search
  [ log_alpha, final_mcd ] = ...
      alpha_mouse_search(log_alpha, log_gamma, data, k, opts);

  %% Plot it
  if opts.plot
    plot_point(exp(log_alpha), exp(log_gamma), final_mcd, true(), opts)
  endif

  %% Output
  opt_alpha = exp(log_alpha);
  opt_gamma = exp((log_gamma_min + log_gamma_max) / 2);

  %% Result
  result("Search", opt_alpha, opt_gamma, opts.s_run, opts);
endfunction


%%%%%%%%%%
%% Main %%
%%%%%%%%%%

%% General options
def_opts              = struct();
def_opts.clusterer    = BREGMAN;
def_opts.clusters     = "sqrt";
def_opts.epsilon_down = 1e-4;
def_opts.epsilon_up   = 1e-3;
def_opts.max_fraction =   0.5;
def_opts.min_alpha    =   0.01;
def_opts.max_alpha    = 100.0;
def_opts.min_gamma    =   0.01;
def_opts.max_gamma    = 100.0;
def_opts.verbose      = false();

%% Plot options
def_opts.plot      = false();
def_opts.p_contour = true();

%% Run options
def_opts.run_clusters = 100;
def_opts.run_repeats  = 100;

%% Manual options
def_opts.man_alpha = [];
def_opts.man_gamma = [];
def_opts.man_run   = false();

%% Grid options
def_opts.grid        = false();
def_opts.g_repeats   =  1;
def_opts.g_n_alpha   = 21;
def_opts.g_n_gamma   = 21;
def_opts.g_run       = false();

%% Search options
def_opts.search         = true();
def_opts.s_epsilon_dist	= 1e-10;
def_opts.s_lemming     	=  2;
def_opts.s_max_denom   	= 10;
def_opts.s_mouse      	=  0.5;
def_opts.s_mouse_change =  0.01;
def_opts.s_mouse_stay   =  3;
def_opts.s_precision    =  0.1;
def_opts.s_repeats      =  5;
def_opts.s_subsample    = [];
def_opts.s_run          = false();

%% Helper functions
function [ opts ] = _sqrt_clusters(opts, value)
  opts.clusters = "sqrt";
endfunction
function [ opts ] = _true_clusters(opts, value)
  opts.clusters = "true";
endfunction
function [ opts ] = _run(opts, value)
  opts.man_run = opts.g_run = opts.s_run = value;
endfunction
function [ opts ] = _s_no_subsample(opts, value)
  opts.s_subsample = [];
endfunction

%% Parse options
[ args, opts ] = ...
    get_options(def_opts, ...
		"cl-bregman=r0",      "clusterer",        ...
		"cl-soft-bbc=r1",     "clusterer",        ...
		"sqrt-clusters",      @_sqrt_clusters,     ...
		"true-clusters",      @_true_clusters,     ...
		"clusters=i",         "clusters",         ...
		"epsilon-down=f",     "epsilon_down",     ...
		"epsilon-up=f",       "epsilon_up",       ...
		"max-fraction=f",     "max_fraction",     ...
		"min-alpha=f",        "min_alpha",        ...
		"max-alpha=f",        "max_alpha",        ...
		"min-gamma=f",        "min_gamma",        ...
		"max-gamma=f",        "max_gamma",        ...
		"verbose!",           "verbose",          ...
		...
		"plot!",              "plot",             ...
		"p-contour!",         "p_contour",        ...
		...
		"run!",               @_run,               ...
		"run-clusters=i",     "run_clusters",     ...
		"run-repeats=i",      "run_repeats",      ...
		...
		"man-alpha=f",        "man_alpha",        ...
		"man-gamma=f",        "man_gamma",        ...
		"man-run!",           "man_run",          ...
		...
		"grid!",              "grid",             ...
		"g-repeats=i",        "g_repeats",        ...
		"g-n-alpha=i",        "g_n_alpha",        ...
		"g-n-gamma=i",        "g_n_gamma",        ...
		"g-run!",             "g_run",            ...
		...
		"search!",            "search",           ...
		"s-epsilon-dist=f",   "s_epsilon_dist",   ...
		"s-lemming=f",        "s_lemming",        ...
		"s-max-denom=i",      "s_max_denom",      ...
		"s-mouse-change=f",   "s_mouse_change",   ...
		"s-mouse-stay=i",     "s_mouse_stay",     ...
		"s-precision=f",      "s_precision",      ...
		"s-subsample=i",      "s_subsample",      ...
		"s-no-subsample",     @_s_no_subsample,    ...
		"s-run!",             "s_run");

%% Arguments
if length(args) ~= 2
  error("Wrong number of arguments: Expected [options] <input> <seed>");
endif

%% Input file
opts.input = args{1};
try
  load(opts.input, "data", "truth");
catch
  error("Cannot load data from '%s': %s", opts.input, lasterr());
end_try_catch

%% Seed
opts.seed = parse_double(args{2}, "seed");

%% Initialize seed
set_all_seeds(opts.seed);

%% Number of clusters
k = determine_clusters(data, truth, opts);

%% Debug
fprintf(2, "k = %d\n", k);

%% Plot
if opts.plot
  create_figure(opts);
endif

%% Manual
if ~isempty(opts.man_alpha) && ~isempty(opts.man_gamma)
  %% Manual
  do_manual(data, k, opts);
endif

%% Grid
if opts.grid
  %% Find it
  do_grid(data, k, opts);
endif

%% Search
if opts.search
  %% Do it
  do_search(data, k, opts);
endif

%% Pause
pause();