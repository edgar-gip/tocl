%% -*- mode: octave; -*-

%% Sequential Expectation-Maximization clustering
%% Main procedure

%% Author: Edgar Gonzalez

function [ expec, model, info ] = cluster(this, data, k, expec_0)

  %% Check arguments
  if ~any(nargin() == [ 3, 4 ])
    usage(cstrcat("[ expec, model, info ] = ", ...
		  "@SeqEM/cluster(this, data, k [, expec_0 ])"));
  endif

  %% Number of clusters
  n_clusterers = length(this.clusterers);

  %% A cell array of data?
  if ~iscell(data)
    %% Generate a data cell with repetitions
    data_cell = cell(1, n_clusterers);
    for c = 1 : n_clusterers
      data_cell{c} = data;
    endfor

    %% Replace
    data = data_cell;
  endif

  %% Size
  [ n_dims_1, n_data ] = size(data{1});

  %% Is the starting expectation given?
  if nargin() < 4
    %% Take it at random
    expec_0 = random_expec(this.clusterers{1}, data{1}, k);

  else
    %% Check the size
    [ expec_0_r, expec_0_c ] = size(expec_0);
    if expec_0_r ~= k || expec_0_c ~= n_data
      usage("expec_0 must be of size k x n_data if present");
    endif
  endif


  %% Current expectation
  expec_i = expec_0;

  %% For each one
  for c = 1 : n_clusterers
    %% Cluster in chain
    [ expec_i, model_i, info_i ] = ...
	cluster(this.clusterers{c}, data{c}, k, expec_i);
  endfor

  %% Info
  info            = struct();
  info.expec_0    = expec_0;
  info.expec_f    = expec_i;
  info.log_like_f = info_i.log_like;

  %% Fit the final model
  if this.final_model == n_clusterers
    %% It is already fit
    expec         = expec_i;
    model         = model_i;
    info.log_like = info_i.log_like;

  else
    %% Final maximization
    model = maximization(this.clusterers{this.final_model}, ...
			 data{this.final_model}, expec_i);

    %% Final expectation
    [ expec, log_like ] = expectation(model, data{this.final_model});

    %% Info
    info.log_like = log_like;
  endif
endfunction
