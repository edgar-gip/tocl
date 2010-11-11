%% -*- mode: octave; -*-

%% Hyper Batch Ball One-Class Clustering
%% Clustering function

%% Author: Edgar Gonzalez

function [ expec, model, info ] = cluster(this, data, k, expec_0)

  %% Check arguments
  if ~any(nargin() == [ 2, 3, 4 ])
    usage(cstrcat("[ expec, model, info ] = ",
		  "@HyperBB/cluster(this, data [, k [, expec_0]])"));
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

  %% First, apply HOCC
  [ mid_expec, mid_model, mid_info ] = cluster(this.hocc, data);

  %% Centroid expectation
  centroid_expec = sparse([ 1 ], mid_info.centroid_idx, [ 1 ], ...
			  1, n_samples);

  %% Then, apply BBOCC
  [ expec, model, info ] = cluster(this.bbocc, data, 1, centroid_expec);

  %% Extend info with mid_info
  for [ value, field ] = mid_info
    info = setfield(info, field, value);
  endfor
endfunction
