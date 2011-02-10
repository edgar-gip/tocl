%% -*- mode: octave; -*-

%% Bayesian Information Criterion
%% Criterion

%% Author: Edgar Gonzalez

function [ criterion ] = apply(this, data, expec, model, info);

  %% Check arguments
  if nargin() ~= 5
    usage("[ criterion ] = @BIC/apply(this, data, expec, model, info)");
  endif

  %% Data size
  [ n_dims, n_data ] = size(data);

  %% Log_like
  if isstruct(info)
    log_like = info.log_like;
  else
    log_like = info;
  endif

  %% -BIC is...
  criterion = 2 * log_like - complexity(model) * log(n_data);
endfunction
