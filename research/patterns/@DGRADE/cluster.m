%% -*- mode: octave; -*-

%% Bregman Bubble Clustering
%% Clustering function

%% Author: Edgar Gonzalez

function [ expec, model, info ] = cluster(this, data, k, expec_0)

  %% Check arguments
  if ~any(nargin() == [ 2, 3, 4 ])
    usage(cstrcat("[ expec, model, info ] = ",
		  "@DGRADE/cluster(this, data [, k [, expec_0]])"));
  endif

  %% The number of clusters must be 1
  if nargin() >= 3 && k ~= 1
    usage("k must be 1 if given");
  endif

  %% Warn that expec_0 is ignored
  if nargin() == 4 && ~isempty(expec_0)
    warning("expec_0 is ignored");
  endif

  %% Size
  [ n_dims, n_samples ] = size(data);
  if n_samples <= this.s_one
    %% Singleton cluster
    %% TODO

  else
    %% Target size
    target_size = round(n_samples * this.size_ratio);

    %% Divergence matrix
    divs = apply(this.divergence, data);
    [ sorted_divs, nearest_neighbours ] = sort(divs, 2);

    %% Cost of bregmanian ball centered on point
    cost = sum(sorted_divs(:, 1 : this.s_one), 2);
    [ sorted_cost, sorted_cost_idx ] = sort(cost);

    %% Find hard expectation, centroids and radius
    k = 0;
    hard_expec = zeros(1, n_samples);
    centroid_indices = [];
    radius = 0;
    for i = 1 : target_size
      idx = sorted_cost_idx(i);
      if this.verbose
	fprintf(2, "Assigning %dth object %d", i, idx);
      endif

      %% Find neighbour of minimum cost
      costs = cost(nearest_neighbours(idx, 1 : this.s_one));
      [ min_cost, min_cost_neighbour_idx ] = min(costs);
      min_cost_idx = nearest_neighbours(idx, min_cost_neighbour_idx);

      %% Is it it himself?
      if min_cost_idx == idx
	%% New cluster
	k += 1;
	hard_expec(idx) = k;
	centroid_indices = [ centroid_indices, idx ];
      else
	%% Same
	hard_expec(idx) = hard_expec(min_cost_idx);
	div_to_centroid = divs(idx, min_cost_idx);
	if div_to_centroid > radius
	  radius = div_to_centroid;
	endif
      endif
    endfor
  endif

  %% Expectation
  expec_on = find(hard_expec);
  expec    = ...
      sparse(hard_expec(expec_on), expec_on, ones(1, length(expec_on)), ...
	     k, n_samples);

  %% Model
  centroids = data(:, centroid_indices);
  model = BregmanBallModel(this.divergence, centroids, radius);

  %% Info
  info = struct();
endfunction
