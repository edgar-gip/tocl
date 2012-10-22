%% -*- mode: octave; -*-

%% Pipeline of clustering methods
%% Clustering function

%% Author: Edgar Gonzalez

function [ expec, model, info ] = cluster(this, data, k, expec_0)

  %% Check arguments
  if ~any(nargin() == [ 2, 3, 4 ])
    usage(cstrcat("[ expec, model, info ] = ",
		  "@Pipeline/cluster(this, data [, k [, expec_0]])"));
  endif

  %% Current k
  if nargin() >= 3
    cur_k = k;
  else
    cur_k = [];
  endif

  %% Current expec_0
  if nargin() == 4
    cur_expec_0 = expec_0;
  else
    cur_expec_0 = [];
  endif

  %% Infos
  infos = {};

  %% Chain methods
  for i = 1 : length(this.methods)
    %% Cluster
    method = this.methods{i};
    [ next_expec, next_model, next_info ] = ...
	cluster(method, data, cur_k, cur_expec_0);

    %% Update
    cur_k = size(next_expec, 1);
    cur_expec_0 = next_expec;
    infos = cell_push(infos, next_info);
  endfor

  %% Final
  expec = next_expec;
  model = next_model;
  info  = struct("inner_info", infos);
endfunction
