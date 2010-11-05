%% -*- mode: octave; -*-

%% Batch Ball One-Class Clustering
%% Clustering function

%% Author: Edgar Gonzalez

function [ expec, model, info ] = cluster(this, data, k, expec_0)

  %% Check arguments
  if ~any(nargin() == [ 2, 3, 4 ])
    usage(cstrcat("[ expec, model, info ] = ",
		  "@BBOCC/cluster(this, data [, k [, expec_0]])"));
  endif

  %% The number of clusters must be 1
  if nargin() >= 3 && k ~= 1
    usage("k must be 1 if given");
  endif

  %% Size
  [ n_feats, n_samples ] = size(data);
  target_size = max([2, round(n_samples * this.size_ratio)]);

  %% expec_0 given?
  if nargin() == 4
    %% Harden the cluster
    cluster  = find(expec_0 > 0.5);
    centroid = mean(data(:, cluster), 2);

  else %% nargin() < 4
    %% Select a starting centroid at random
    cluster  = floor(1 + n_samples * rand(1));
    centroid = data(:, cluster);
  endif

  %% Starting radius -> Infinity
  radius = inf;

  %% Final
  final = false();
  while ~final
    %% Preserve previous cluster, centroid and radius
    p_cluster  = cluster;
    %% p_centroid = centroid;
    %% p_radius   = radius;

    %% Find the divergences
    divs = apply(this.divergence, centroid, data);

    %% Sort the matrix
    [ sort_divs, sort_indices ] = sort(divs);

    %% New cluster and centroid
    radius   = sort_divs(target_size);
    cluster  = find(divs <= radius);
    centroid = mean(data(:, cluster), 2);

    %% Changes
    n_changes = length(setxor(cluster, p_cluster));
    final     = n_changes < this.change_threshold;
  endwhile

  %% Model
  model = BregmanBallModel(this.divergence, centroid, radius);

  %% Expectation
  size  = length(cluster);
  expec = sparse(ones(1, size), cluster, ones(1, size), ...
		 1, n_samples);

  %% Info
  info = struct();
endfunction
