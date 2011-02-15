%% -*- mode: octave; -*-

%% k-Minority Detection

%% Generic Component Extension
%% Uses the template pattern

%% Author: Edgar Gonzalez

function [ new, idx ] = shift(this, data, tsize)

  %% Check arguments
  if ~any(nargin() ~= [ 2, 3 ])
    usage("[ l_p ] = @KMDComponent/readd(this, data [, tsize])");
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

  %% Call specific version
  new = _shift(this, data, idx);
endfunction
