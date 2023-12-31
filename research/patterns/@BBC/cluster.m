%% -*- mode: octave; -*-

%% Bregman Bubble Clustering
%% Clustering function

%% Author: Edgar Gonzalez

function [ expec, model, info ] = cluster(this, data, k, expec_0)

  %% Check arguments
  if ~any(nargin() == [ 3, 4 ])
    usage(cstrcat("[ expec, model, info ] = ",
                  "@BBC/cluster(this, data, k [, expec_0]])"));
  endif

  %% Size
  [ n_dims, n_samples ] = size(data);
  target_size = max([2, k, round(n_samples * this.size_ratio)]);

  %% expec_0 given?
  if nargin() == 4
    %% Find maximal cluster
    [ p, cl ] = max(expec_0);

    %% Take only those classified
    on   = find(p > 0.0);
    n_on = length(on);

    %% Make the expectation
    expec = sparse(cl(on), on, ones(1, n_on), k, n_samples);

  else %% nargin() < 4
    %% Select seeds
    seeds = sort(randperm(n_samples)(1 : k));

    %% Make the expectation
    expec = sparse(1 : k, seeds, ones(1, k), k, n_samples);
  endif

  %% Cluster sizes
  sizes = full(sum(expec, 2))'; % 1 * k

  %% Cluster centroids
  centroids = (data * expec') ./ (ones(n_dims, 1) * sizes); % n_dims * k

  %% Starting radius -> Infinity
  radius = inf;

  %% Final
  final = false();
  while ~final
    %% Preserve previous expec, centroid and radius
    p_expec = expec;
    %% p_centroids = centroids;
    %% p_radius   = radius;

    %% Find the divergences
    divs = apply(this.divergence, centroids, data);

    %% Select the closest cluster
    [ min_divs, min_indices ] = min(divs);

    %% Sort the clusters
    [ sort_divs, sort_indices ] = sort(min_divs);

    %% Which will be classified?
    radius = sort_divs(target_size);
    on     = find(min_divs <= radius);
    n_on   = length(on);

    %% Make the expectation
    expec = sparse(min_indices(on), on, ones(1, n_on), k, n_samples);

    %% Cluster sizes
    sizes = full(sum(expec, 2))'; % 1 * k

    %% Cluster centroids
    centroids = (data * expec') ./ (ones(n_dims, 1) * sizes); % n_dims * k

    %% Changes
    n_changes = full(sum(sum(xor(expec, p_expec))));
    final     = n_changes < this.change_threshold;
  endwhile

  %% Model
  model = BregmanBallModel(this.divergence, centroids, radius);

  %% Info
  info = struct();
endfunction
