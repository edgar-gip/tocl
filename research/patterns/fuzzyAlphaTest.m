%% -*- mode: octave; -*-

%% Test alpha value for fuzzy clustering

%% Author: Edgar Gonzàlez i Pellicer


%% Octopus
pkg load octopus

%% Extra path
addpath(binrel("private"));

%% Epsilon parameter
epsilon = 1e-12;


%%%%%%%%%%%%%
%% Helpers %%
%%%%%%%%%%%%%

function [ values ] = log_stepped_values(min_value, max_value, n_steps)
  %% Bounds
  log_min = log(min_value);
  log_max = log(max_value);

  %% Step
  step = (log_max - log_min) / (n_steps - 1);

  %% Values
  values = exp(log_min + step * ((1 : n_steps) - 1));
endfunction

function log_contour(xl, yl, zl, x, y, z)
  %% Plot
  figure("name", zl);
  contour(x, y, z);

  %% Log-plots
  set(gca(), "xscale", "log");
  set(gca(), "yscale", "log");

  %% Labels
  xlabel(xl);
  ylabel(yl);
endfunction


%%%%%%%%%%
%% Data %%
%%%%%%%%%%

%% Generate the data
function [ data, truth, centr ] = gen_data(clusters, csize, radius, variance)
  %% Angle
  angle = 2 * pi / clusters;

  %% Total size
  total = clusters * csize;

  %% Data, truth
  data  = zeros(2, total);
  truth = zeros(1, total);
  centr = zeros(2, clusters);

  %% For each one
  base = 1;
  for c = 1 : clusters
    %% Centroid
    centr(:, c) = radius * [ cos(c * angle), sin(c * angle) ];

    %% Data
    data(:, base : base + (csize - 1)) = ...
	centr(:, c) * ones(1, csize) + variance * randn(2, csize);

    %% Truth
    truth(base : base + (csize - 1)) = c;

    %% Next
    base += csize;
  endfor
endfunction


%%%%%%%%%%%%
%% Bounds %%
%%%%%%%%%%%%

%% From autoFuzzyParams.m

%% Minimum alpha value
%% \min \alpha s.t.
%% \frac{e^{-\alpha d_{min}}}
%%      {e^{-\alpha d_{min}} + (k - 1) e^{-\alpha d_{max}}} >
%% \frac{1}{k} + \epsilon
function [ alpha_min ] = mininum_alpha(d_min, d_max, k, epsilon)
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


%%%%%%%%%%
%% Main %%
%%%%%%%%%%

%% Get the parameters
args = argv();

%% Check parameter length
if length(args) ~= 7
  error(cstrcat("Wrong number of arguments: Expected", ...
		" <input>", ...
		" <min_alpha> <max_alpha> <alpha_steps>", ...
		" <min_gamma> <max_gamma> <gamma_steps>"));
endif

%% Input argument format
if ~isempty(tokens =
	    regexp(args{1}, ...
		   "^(\\d+)x(\\d+)xN\\(([\\d\\.]+),([\\d\\.]+)\\)$", ...
		   "once", "tokens"))
  %% Generate the data
  clusters  = parse_double(tokens{1}, "number of clusters");
  csize     = parse_double(tokens{2}, "size");
  radius    = parse_double(tokens{3}, "radius");
  variance  = parse_double(tokens{4}, "variance");

  %% Generate the data
  [ data, truth, centr ] = gen_data(clusters, csize, radius, variance);

else
  %% With a scaling prefix?
  if ~isempty(tokens = regexp(args{1}, "^(\\d+)x(.+)$", "once", "tokens"))
    %% Scale
    scale_factor = parse_double(tokens{1}, "scaling factor");
    file         = tokens{2};

  else
    %% Raw file
    scale_factor = [];
    file         = args{1};
  endif

  %% Load a file
  load(file, "data", "truth");

  %% Scale the data
  if ~isempty(scale_factor)
    data *= scale_factor;
  endif

  %% Number of clusters
  clusters = max(truth);
endif

%% Parse the rest of argumets
min_alpha = parse_double(args{2}, "minimum alpha");
max_alpha = parse_double(args{3}, "maximum alpha");
n_alpha   = parse_double(args{4}, "alpha steps");
min_gamma = parse_double(args{5}, "minimum gamma");
max_gamma = parse_double(args{6}, "maximum gamma");
n_gamma   = parse_double(args{7}, "gamma steps");

%% Size
[ n_dims, n_data ] = size(data);

%% Plot it
if size(data, 1) == 2
  pairwise_cluster_plot(data, truth, "Truth");
endif

%% Functions
sods = pcs = mpcs = pes = fss = zeros(1, n_alpha);

%% Alpha values
alpha_values = log_stepped_values(min_alpha, max_alpha, n_alpha);
gamma_values = log_stepped_values(min_gamma, max_gamma, n_gamma);

%% Grid
[ alpha, gamma ] = meshgrid(alpha_values, gamma_values);

%% Output
centroid_distance_true = zeros(n_gamma, n_alpha);
centroid_distance_sqrt = zeros(n_gamma, n_alpha);

%% Estimated clusters
sqrt_clusters = max([ 2, floor(sqrt(n_data)) ]);

%% All-distance matrix
dists    = apply(SqEuclideanDistance(), data);
min_dist = min(min(dists + inf * eye(n_data)));
max_dist = max(max(dists));
clear dists

%% Bounds
printf("alpha > %8g / %8g\n", ...
       mininum_alpha(0, 2, clusters, epsilon), ...
       mininum_alpha(0, 2, sqrt_clusters, epsilon));
printf("%g < gamma < %8g\n", ...
       minimum_gamma(max_dist, epsilon), ...
       maximum_gamma(min_dist, epsilon));

%% For each one
for i = 1 : n_gamma
  for j = 1 : n_alpha
    %% Clusterer
    clusterer = BregmanEM(KernelDistance(RBFKernel(gamma(i, j))), ...
			  struct("beta", alpha(i, j)));

    %% True

    %% Cluster
    [ expec, model ] = cluster(clusterer, data, clusters);

    %% Centroids
    cs = centroids(model);

    %% Distance
    dists         = apply(SqEuclideanDistance(), cs) + inf * eye(clusters);
    min_dist_true = min(min(dists));

    %% %% Sqrt

    %% %% Cluster
    %% [ expec, model ] = cluster(clusterer, data, sqrt_clusters);

    %% %% Centroids
    %% cs = centroids(model);

    %% %% Distance
    %% dists = apply(SqEuclideanDistance(), cs) + inf * eye(sqrt_clusters);

    %% %% Minimum distance
    %% min_dist_sqrt = min(min(dists));

    %% %% Log
    fprintf("a_%3d=%8g g_%3d = %8g --> %8g / %8g\n", ...
     	    j, alpha(i, j), i, gamma(i, j), min_dist_true, min_dist_true);

    %% Store it
    centroid_distance_true(i, j) = min_dist_true;
    centroid_distance_sqrt(i, j) = min_dist_true;
  endfor
endfor

%% True
log_contour("alpha", "gamma", "True clusters", ...
	    alpha, gamma, centroid_distance_true);
log_contour("alpha", "gamma", "True clusters", ...
	    alpha, gamma, centroid_distance_true > epsilon);

%% Sqrt
log_contour("alpha", "gamma", "SPQR clusters", ...
	    alpha, gamma, centroid_distance_sqrt);
log_contour("alpha", "gamma", "SPQR clusters", ...
	    alpha, gamma, centroid_distance_sqrt > epsilon);

%% Wait
pause();
