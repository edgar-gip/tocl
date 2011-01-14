%% -*- mode: octave; -*-

%% Bregman Bubble Clustering (with Pressurization)
%% Clustering function

%% Author: Edgar Gonzalez

function [ expec, model, info ] = cluster(this, data, k, expec_0)

  %% Check arguments
  if ~any(nargin() == [ 3, 4 ])
    usage(cstrcat("[ expec, model, info ] = ",
		  "@BBCPress/cluster(this, data, k [, expec_0]])"));
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

  %% Size
  factor = (n_samples - target_size);

  %% Outer loop
  outer_final = false();
  while ~outer_final
    %% Effective target size
    effective_target_size = floor(target_size + factor);

    %% Inner final
    inner_final = false();

    %% Inner loop
    i = 2;
    while i <= this.max_iterations && ~inner_final
      %% Preserve previous expec, centroid and radius
      p_expec = expec;
      %% p_centroids = centroids;
      %% p_radius   = radius;

      %% Find the divergences
      divs = apply(this.divergence, centroids, data);

      %% Only one cluster?
      if k == 1
	%% It's it
	min_divs    = divs;
	min_indices = ones(1, n_samples);
      else
	%% Select the closest cluster
	[ min_divs, min_indices ] = min(divs);
      endif

      %% Sort the clusters
      [ sort_divs, sort_indices ] = sort(min_divs);

      %% Which will be classified?
      radius = sort_divs(effective_target_size);
      on     = find(min_divs <= radius);
      n_on   = length(on);

      %% Make the expectation
      expec = sparse(min_indices(on), on, ones(1, n_on), k, n_samples);

      %% Cluster sizes
      sizes = full(sum(expec, 2))'; % 1 * k

      %% Cluster centroids
      centroids = (data * expec') ./ (ones(n_dims, 1) * sizes); % n_dims * k

      %% Changes
      n_changes   = full(sum(sum(xor(expec, p_expec))));
      inner_final = n_changes < this.change_threshold;

      %% Next iteration
      ++i;
    endwhile

    %% Update factor
    if factor > 1
      factor *= this.press_decay;
    else
      outer_final = true();
    endif
  endwhile

  %% Model
  model = BregmanBallModel(this.divergence, centroids, radius);

  %% Info
  info = struct();
endfunction
