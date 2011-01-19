%% -*- mode: octave; -*-

%% Truly random clustering
%% Expectation

%% Author: Edgar Gonzalez

function [ expec, log_like ] = expectation(this, data)

  %% Check arguments
  if nargin() ~= 2
    usage("[ expec, log_like ] = @RandomModel/expectation(this, data)");
  endif

  %% Size
  [ n_dims, n_data ] = size(data);

  %% Hard or soft?
  if isfinite(this.concentration)
    %% Soft

    %% Symmetric Dirichlet distribution
    %% Generated from a Gamma distribution
    expec   = gamma_rnd(this.concentration, 1.0, this.k, n_data);
    expec ./= ones(this.k, 1) * sum(expec);

  else
    %% Hard
    cl    = 1 + floor(this.k * rand(1, n_data));
    expec = sparse(cl, 1 : n_data, ones(1, n_data), this.k, n_data);
  endif

  %% Log-like is not considered here
  log_like = nan;
endfunction
