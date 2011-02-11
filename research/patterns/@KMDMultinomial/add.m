%% -*- mode: octave; -*-

%% k-Minority Detection

%% Multinomial Component Extension

%% Author: Edgar Gonzalez

function [ idx ] = add(this, data, tsize)

  %% Check arguments
  if ~any(nargin() ~= [ 2, 3 ])
    usage("[ l_p ] = @KMDMultinomial/add(this, data [, tsize])");
  endif

  %% Size
  [ n_dims, n_data ] = size(data);

  %% No size, or more than there is
  if nargin() < 3 || tsize >= n_data
    %% Take them all
    idx = 1 : n_data;

  else
    %% Find the log_likelihood
    ll = log_likelihood(this, data);

    %% Sort them
    [ best_ll, best_idx ] = sort(ll, "descend");

    %% Take the maximum
    idx = sort(best_idx(1 : tsize));
  endif

  %% Update unnormalized thetas
  this.un_theta += sum(data(:, idx), 2)';

  %% Find the total vocabulary size
  this.un_total = sum(this.un_theta);

  %% Find the log-thetas
  this.log_theta = log((1 + this.un_theta) / (this.n_dims + this.un_total));
endfunction
