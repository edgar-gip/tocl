%% -*- mode: octave; -*-

%% Plot transitions (catastrophes) is RBFKernel Bregman Clustering
%% parameters

%% Author: Edgar Gonzàlez i Pellicer


%% Octopus
pkg load octopus;

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


%%%%%%%%%%
%% Plot %%
%%%%%%%%%%

%% Plot a grid
function [ fh ] = plot_grid(title, alpha, gamma, values)
  %% Figure
  fh = figure("name", title);

  %% Log-plots
  set(gca(), "xscale", "log");
  set(gca(), "yscale", "log");

  %% Labels
  xlabel("alpha");
  ylabel("gamma");

  %% Hold on tight
  hold on;

  %% Plot the contour
  cs = contour(alpha, gamma, values);

  %% Levels
  levels = [];
  i = 1;
  while i < size(cs, 2)
    levels = [ levels, cs(1, i) ];
    i     += cs(2, i) + 1;
  endwhile

  %% Sort the levels, and add an infinity one
  levels = [ unique(levels), inf ];

  %% Grid
  [ aa, gg ] = meshgrid(alpha, gamma);

  %% Not assigned
  assigned = false(size(values));

  %% Plots
  plots = {};
  for l = levels
    %% Find the indices
    idx = find(values < l & ~assigned);

    %% Any?
    if ~isempty(idx)
      %% Add them
      plots = cell_push(plots, aa(idx), gg(idx), "*", "linewidth", 2);

      %% Already assigned
      assigned(idx) = true();
    endif
  endfor

  %% Plot the points
  plot(plots{:});
endfunction


%%%%%%%%%%%%%%%
%% Functions %%
%%%%%%%%%%%%%%%

%% Centroid distance
function [ min_cd, max_cd ] = centroid_distance(model)
  %% Centroids
  cs = centroids(model);
  k  = size(cs, 2);

  %% Distance
  dists  = apply(SqEuclideanDistance(), cs);
  min_cd = min(min(dists + inf * eye(k)));
  max_cd = max(max(dists));

  %% Correction for infinite distances
  %% This means that only one centroid is left alive...
  if ~isfinite(min_cd)
    min_cd = 0;
  endif
endfunction


%% Centroid shift
function [ cshift ] = centroid_shift(src_model, tgt_model)
  %% Centroids
  src_cs = centroids(src_model);
  tgt_cs = centroids(tgt_model);

  %% Shift
  cshifts = sum((tgt_cs - src_cs) .^ 2, 1);
  cshift  = mean(cshifts(~isnan(cshifts)));
endfunction


%% Noise expectation
function [ nexpec ] = noise_expec(expec)
  %% Noise expectation
  nexpec = 1.0 - mean(sum(expec, 1));
endfunction


%%%%%%%%%%%
%% Event %%
%%%%%%%%%%%

%% Do the event
function do_event(alpha, gamma, data, k, fhs, opts)
  %% Within range?
  if opts.min_alpha <= alpha && alpha <= opts.max_alpha && ...
     opts.min_gamma <= gamma && gamma <= opts.max_gamma
    %% For each figure
    for fh = fhs
      %% Plot it
      figure(fh);
      plot(alpha, gamma, "g*", "linewidth", 8);
      replot();
    endfor
  endif

  %% Log
  printf("gamma = %12g\n", gamma);

  %% K-Means clusterer
  kmeans = KMeans(KernelDistance(RBFKernel(gamma)));

  %% Cluster
  [ km_expec, km_model ] = cluster(kmeans, data, k);

  %% Log
  printf("* alpha = %12g", alpha);

  %% SoftBregman clusterer
  sbreg = SoftBBCEM(KernelDistance(RBFKernel(gamma)),           ...
                    struct("beta",          alpha,              ...
                           "em_threshold",  opts.em_threshold,  ...
                           "em_iterations", opts.em_iterations, ...
                           "plot",          opts.em_plot));

  %% Cluster
  [ sb_expec, sb_model ] = cluster(sbreg, data, k, km_expec);

  %% Extra plot
  if opts.em_plot
    %% Hold
    hold on;

    %% Add title
    title(sprintf("alpha = %g gamma = %g", alpha, gamma));

    %% Plot centroids
    cs = centroids(sb_model);
    plot(cs(1, :), cs(2, :), "*", "linewidth", 8);

    %% Update
    replot();
  endif

  %% Now, find each function
  [ min_cd, max_cd ] = centroid_distance(sb_model);
  %% [ cshift         ] = centroid_shift(km_model, sb_model);
  [ nexpec         ] = noise_expec(sb_expec);

  %% Derived
  nx_mcd = min_cd * nexpec;

  %% Log
  printf("\tmin_cd = %12g",   min_cd);
  printf("\tmax_cd = %12g",   max_cd);
  %% printf("\tcshift = %12g",   cshift);
  printf("\tnexpec = %12g",   nexpec);
  printf("\tnx_mcd = %12g\n", nx_mcd);

  %% Run
  if opts.run
    %% Command string
    cmd = sprintf(cstrcat("octave -p %s -q %s %s %s rbf %g",          ...
                          " ewocs_voro %g,%d,%d 1 %d"),               ...
                  binrel(), binrel("scoreAndoData.m"), opts.run_mode, ...
                  opts.input, gamma, alpha, opts.run_repeats,         ...
                  opts.run_clusters, opts.seed);

    %% Display it
    printf("*** %s\n", cmd);

    %% Run it
    system(cmd);
  endif
endfunction


%%%%%%%%%%
%% Main %%
%%%%%%%%%%

%% General options
def_opts                          = struct();
def_opts.clusters                 = "sqrt";
def_opts.em_iterations            =   20;
def_opts.em_plot          = true();
def_opts.em_threshold             = 1e-6;
def_opts.min_alpha                =    0.01;
def_opts.max_alpha                = 1000.0;
def_opts.n_alpha          =   26;
def_opts.min_gamma                =    0.01;
def_opts.max_gamma                = 1000.0;
def_opts.n_gamma          =   26;
def_opts.verbose                  = false();

%% Run options
def_opts.run          = false();
def_opts.run_mode     = "--basic";
def_opts.run_clusters = 100;
def_opts.run_repeats  = 100;

%% Helper functions
function [ opts ] = _sqrt_clusters(opts, value)
  opts.clusters = "sqrt";
endfunction
function [ opts ] = _true_clusters(opts, value)
  opts.clusters = "true";
endfunction
function [ opts ] = _run_basic(opts, value)
  opts.run_mode = "--basic";
endfunction
function [ opts ] = _run_full(opts, value)
  opts.run_mode = "--full";
endfunction
function [ opts ] = _run_extra(opts, value)
  opts.run_mode = "--extra";
endfunction

%% Parse options
[ args, opts ] = ...
    get_options(def_opts, ...
                "sqrt-clusters",   @_sqrt_clusters, ...
                "true-clusters",   @_true_clusters, ...
                "clusters=i",      "clusters",      ...
                "em-iterations=i", "em_iterations", ...
                "em-plot!",        "em_plot",       ...
                "em-threshold=f",  "em_threshold",  ...
                "min-alpha=f",     "min_alpha",     ...
                "max-alpha=f",     "max_alpha",     ...
                "n-alpha=i",       "n_alpha",       ...
                "min-gamma=f",     "min_gamma",     ...
                "max-gamma=f",     "max_gamma",     ...
                "n-gamma=i",       "n_gamma",       ...
                "verbose!",        "verbose",       ...
                ...
                "run!",            "run",           ...
                "run-basic",       @_run_basic,     ...
                "run-full",        @_run_full,      ...
                "run-extra",       @_run_extra,     ...
                "run-clusters=i",  "run_clusters",  ...
                "run-repeats=i",   "run_repeats");

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
printf("k = %d\n", k);

%% Alpha/gamma values
alpha = log_series(opts.min_alpha, opts.max_alpha, opts.n_alpha);
gamma = log_series(opts.min_gamma, opts.max_gamma, opts.n_gamma);

%% Output
min_cd = zeros(opts.n_gamma, opts.n_alpha);
max_cd = zeros(opts.n_gamma, opts.n_alpha);
%% cshift = zeros(opts.n_gamma, opts.n_alpha);
nexpec = zeros(opts.n_gamma, opts.n_alpha);
nx_mcd = zeros(opts.n_gamma, opts.n_alpha);

%% For each gamma
for j = 1 : opts.n_gamma
  %% Log
  printf("gamma = %12g\n", gamma(j));

  %% K-Means clusterer
  kmeans = KMeans(KernelDistance(RBFKernel(gamma(j))));

  %% Cluster
  [ km_expec, km_model ] = cluster(kmeans, data, k);

  %% For each alpha
  for i = 1 : opts.n_alpha
    %% Log
    printf("* alpha = %12g", alpha(i));

    %% SoftBregman clusterer
    sbreg = SoftBBCEM(KernelDistance(RBFKernel(gamma(j))),       ...
                      struct("beta",          alpha(i),          ...
                             "em_threshold",  opts.em_threshold, ...
                             "em_iterations", opts.em_iterations));

    %% Cluster
    [ sb_expec, sb_model ] = cluster(sbreg, data, k, km_expec);

    %% Now, find each function
    [ min_cd(j, i), max_cd(j, i) ] = centroid_distance(sb_model);
    %% [ cshift(j, i)               ] = centroid_shift(km_model, sb_model);
    [ nexpec(j, i)               ] = noise_expec(sb_expec);

    %% Derived
    nx_mcd(j, i) = min_cd(j, i) * nexpec(j, i);

    %% Log
    printf("\tmin_cd = %12g",   min_cd(j, i));
    printf("\tmax_cd = %12g",   max_cd(j, i));
    %% printf("\tcshift = %12g",   cshift(j, i));
    printf("\tnexpec = %12g",   nexpec(j, i));
    printf("\tnx_mcd = %12g\n", nx_mcd(j, i));
  endfor
endfor

%% Plot
fhs = [ plot_grid("Min Centroid Distance", alpha, gamma, min_cd), ...
        plot_grid("Max Centroid Distance", alpha, gamma, max_cd), ...
        ... %% plot_grid("Mean Centroid Shift",   alpha, gamma, cshift),
        plot_grid("Noise Expectation",     alpha, gamma, nexpec), ...
        plot_grid("N. Exp * Min C.D.",     alpha, gamma, nx_mcd) ];

%% Event loop
finish = false();
while ~finish
  %% Get an event
  figure(fhs(1));
  [ alpha, gamma, button ] = ginput(1);

  %% Key
  switch button
    case 1
      do_event(alpha, gamma, data, k, fhs, opts);

    case -1
      finish = true();
  endswitch
endwhile
