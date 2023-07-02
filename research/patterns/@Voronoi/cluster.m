%% -*- mode: octave; -*-

%% Voronoi clustering
%% Main procedure

%% Author: Edgar Gonzalez

function [ expec, model, info ] = cluster(this, data, k, expec_0)

  %% Check arguments
  if ~any(nargin() == [ 3, 4 ])
    usage(cstrcat("[ expec, model, info ] = ", ...
                  "@Voronoi/cluster(this, data, k [, expec_0])"));
  endif

  %% Size
  [ n_dims, n_data ] = size(data);

  %% Is the starting expectation given?
  if nargin() < 4
    %% Take seeds at random
    seeds = sort(randperm(n_data)(1 : k));

  else
    %% Check size
    [ expec_0_r, expec_0_c ] = size(expec_0);
    if expec_0_r ~= k || expec_0_c ~= n_data
      usage("expec_0 must be of size k x n_data if present");
    endif

    % Take as seed the one set
    [ dummy, seeds ] = max(expec_0');
  endif

  %% Create the model
  model = VoronoiModel(this.soft_alpha, this.distance, data(:, seeds));

  %% Find the expectation
  [ expec, log_like ] = expectation(model, data);

  %% Return the information
  info          = struct();
  info.seeds    = seeds;
  info.log_like = log_like;
endfunction
