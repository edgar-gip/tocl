%% -*- mode: octave; -*-

%% k-Means clustering
%% Main procedure

%% Author: Edgar Gonzalez

function [ expec, model, info ] = cluster(this, data, k, expec_0)

  %% Check arguments
  if ~any(nargin() == [ 3, 4 ])
    usage(cstrcat("[ expec, model, info ] = ", ...
                  "@KMeans/cluster(this, data, k [, expec_0])"));
  endif

  %% Size
  [ n_dims, n_samples ] = size(data);

  %% Only one cluster?
  if k == 1
    %% Return a single cluster model
    expec = ones(1, n_samples);
    model = AllModel();
    info  = struct();
    return
  endif

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
    %% Take it at random
    expec = random_expec(this, data, k);
  endif

  %% Cluster sizes
  sizes = full(sum(expec, 2))'; % 1 * k

  %% Cluster centroids
  centroids = (data * expec') ./ (ones(n_dims, 1) * sizes); % n_dims * k

  %% Effective change threshold
  if this.change_threshold < 1.0
    eff_change_threshold = this.change_threshold * n_samples;
  else
    eff_change_threshold = this.change_threshold;
  endif

  %% Final
  final = false();

  %% Loop
  i = 2;
  while i <= this.max_iterations && ~final
    %% Preserve previous expec
    p_expec = expec;

    %% Find the divergences
    divs = apply(this.divergence, centroids, data);

    %% Select the closest cluster
    [ min_divs, min_indices ] = min(divs);

    %% Make the expectation
    expec = sparse(min_indices, 1 : n_samples, ones(1, n_samples), ...
                   k, n_samples);

    %% Cluster sizes
    sizes = full(sum(expec, 2))'; % 1 * k

    %% Cluster centroids
    centroids = (data * expec') ./ (ones(n_dims, 1) * sizes); % n_dims * k

    %% Changes
    n_changes = full(sum(sum(xor(expec, p_expec))));
    final     = n_changes < eff_change_threshold;

    %% Next iteration
    ++i;
  endwhile

  %% Create the model
  model = KMeansModel(this.divergence, centroids);

  %% Return the information
  info            = struct();
  info.iterations = i;
endfunction
