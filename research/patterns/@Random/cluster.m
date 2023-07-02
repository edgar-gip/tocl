%% -*- mode: octave; -*-

%% Truly random clustering
%% Main procedure

%% Author: Edgar Gonzalez

function [ expec, model, info ] = cluster(this, data, k, expec_0)

  %% Check arguments
  if ~any(nargin() == [ 3, 4 ])
    usage(cstrcat("[ expec, model, info ] = ", ...
                  "@Random/cluster(this, data, k [, expec_0])"));
  endif

  %% Size
  [ n_dims, n_data ] = size(data);

  %% Warn that expec_0 is ignored
  %% if nargin() == 4 && ~isempty(expec_0)
  %%   warning("expec_0 is ignored");
  %% endif

  %% Create the model
  model = RandomModel(this.concentration, k);

  %% Find the expectation
  [ expec, log_like ] = expectation(model, data);

  %% Return the information
  info          = struct();
  info.log_like = log_like;
endfunction
