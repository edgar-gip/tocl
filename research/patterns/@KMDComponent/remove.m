%% -*- mode: octave; -*-

%% k-Minority Detection

%% Generic Component Reduction
%% Uses the template pattern

%% Author: Edgar Gonzalez

function [ new, idx ] = remove(this, data, tsize)

  %% Check arguments
  if ~any(nargin() ~= [ 2, 3 ])
    usage("[ l_p ] = @KMDComponent/remove(this, data [, tsize])");
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
    [ worst_ll, worst_idx ] = sort(ll);

    %% Take the minimum
    idx = sort(worst_idx(1 : tsize));
  endif

  %% Call specific version
  new = _remove(this, data, idx);
endfunction
