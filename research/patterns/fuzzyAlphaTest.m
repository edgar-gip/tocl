%% -*- mode: octave; -*-

%% Test alpha value for fuzzy clustering

%% Author: Edgar Gonzàlez i Pellicer


%% Octopus
pkg load octopus

%% Extra path
addpath(binrel("private"));


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


%%%%%%%%%%%%%%
%% Criteria %%
%%%%%%%%%%%%%%

%% Partition coefficient
function [ pc, mpc ] = partition_coefficient(probability)
  %% Sizes
  [ k, n_data ] = size(probability);

  %% Add
  pc = sum(sum(probability .^ 2)) / n_data;

  %% Modified
  mpc = 1 - k / (k - 1) * (1 - pc);
endfunction

%% Partition entropy
function [ pe ] = partition_entropy(probability)
  %% Length
  n_data = size(probability, 2);

  %% Add
  pe = -sum(sum(probability .* log(probability))) / n_data;
endfunction

%% Sum of distances
function [ sod ] = sum_of_distances(probability, dists)
  %% Length
  n_data = size(probability, 2);

  %% Multiply and add
  sod = sum(sum(probability .* dists));
endfunction

%% Fukuyama-Sugeno
function [ fs ] = fukuyama_sugeno(probability, dists, cdists)
  %% Length
  n_data = size(probability, 2);

  %% Correct distances
  dists -= cdists' * ones(1, n_data);

  %% Multiply and add
  fs = sum(sum(probability .* dists));
endfunction

%% FHV
function [ fhv ] = fuzzy_hypervolume(probability, dists);

endfunction


%%%%%%%%%%
%% Main %%
%%%%%%%%%%

%% Parse double
function [ value ] = parse_double(label, string)
  [ value, status ] = str2double(string);
  if status ~= 0
    error("Wrong %s '%s'", label, string)
  endif
endfunction

%% Get the parameters
args = argv();

%% Check parameter length
if length(args) ~= 10
  error(cstrcat("Wrong number of arguments: Expected", ...
		" <clusters> <size> <radius> <variance>", ...
		" <min_alpha> <max_alpha> <alpha_steps>", ...
		" <min_gamma> <max_gamma> <gamma_steps>"));
endif

%% Parse argumets
clusters  = parse_double("number of clusters", args{1});
csize     = parse_double("size",               args{2});
radius    = parse_double("radius",             args{3});
variance  = parse_double("variance",           args{4});
min_alpha = parse_double("minimum alpha",      args{5});
max_alpha = parse_double("maximum alpha",      args{6});
n_alpha   = parse_double("alpha steps",        args{7});
min_gamma = parse_double("minimum gamma",      args{8});
max_gamma = parse_double("maximum gamma",      args{9});
n_gamma   = parse_double("gamma steps",        args{10});

%% Generate the data
[ data, truth, centr ] = gen_data(clusters, csize, radius, variance);

%% Plot it
pairwise_cluster_plot(data, truth, "Truth");

%% Distance matrix
%% dists  = apply(SqEuclideanDistance(), centr,       data);
%% cdists = apply(SqEuclideanDistance(), zeros(2, 1), centr);

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

%% Size
[ n_dims, n_data ] = size(data);

%% Estimated clusters
sqrt_clusters = max([ 2, floor(sqrt(n_data)) ]);

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

    %% Sqrt

    %% Cluster
    [ expec, model ] = cluster(clusterer, data, sqrt_clusters);

    %% Centroids
    cs = centroids(model);

    %% Distance
    dists = apply(SqEuclideanDistance(), cs) + inf * eye(sqrt_clusters);

    %% Minimum distance
    min_dist_sqrt = min(min(dists));

    %% Log
    fprintf("a_%3d=%8g g_%3d = %8g --> %8g / %8g\n", ...
	    j, alpha(i, j), i, gamma(i, j), min_dist_true, min_dist_sqrt);

    %% Store it
    centroid_distance_true(i, j) = min_dist_true;
    centroid_distance_sqrt(i, j) = min_dist_sqrt;
  endfor
endfor

%% True

%% Plot
figure("name", "True clusters");
contour(alpha, gamma, centroid_distance_true);

%% Log-plots
set(gca(), "xscale", "log");
set(gca(), "yscale", "log");

%% Labels
xlabel("alpha");
ylabel("gamma");

%% Sqrt

%% Plot
figure("name", "SPQR clusters");
contour(alpha, gamma, centroid_distance_sqrt);

%% Log-plots
set(gca(), "xscale", "log");
set(gca(), "yscale", "log");

%% Labels
xlabel("alpha");
ylabel("gamma");

%% Wait
pause();
