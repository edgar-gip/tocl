%% -*- mode: octave; -*-

%% Density Gradient Enumeration (DGRADE)
%% Clustering helper function

%% Author: Edgar Gonzalez

function [ hard_expec, centroid_indices, radius ] = ...
      cluster_sone(this, n_samples, target_size, s_one, ...
		   divs, sorted_divs, nearest_neighbours)
  %% Cost of bregmanian ball centered on point
  cost = sum(sorted_divs(:, 1 : s_one), 2);
  [ sorted_cost, sorted_cost_idx ] = sort(cost);

  %% Find hard expectation, centroids and radius
  k = 0;
  hard_expec = zeros(1, n_samples);
  centroid_indices = [];
  radius = 0;
  for i = 1 : target_size
    idx = sorted_cost_idx(i);

    %% Find neighbour of minimum cost
    costs = cost(nearest_neighbours(idx, 1 : s_one));
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
endfunction
