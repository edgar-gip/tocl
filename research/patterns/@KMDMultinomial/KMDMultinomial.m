%% -*- mode: octave; -*-

%% k-Minority Detection

%% Multinomial Component Constructor

%% Author: Edgar Gonzalez

function [ this ] = KMDMultinomial(first, un_theta)

  %% Check arguments
  if ~any(nargin() == [ 1, 2 ])
    usage("[ this ] = KMDMultinomial(data | n_dims, un_theta)");
  endif

  %% Data was given?
  if nargin() == 1
    %% Size
    [ n_dims, n_data ] = size(first);

    %% Find the unnormalized thetas
    un_theta = full(sum(first, 2))';

  else
    %% Fetch
    n_dims = first;
  endif

  %% This object
  this = struct();

  %% Set fields
  this.n_dims   = n_dims;
  this.un_theta = un_theta;

  %% Find the total vocabulary size
  un_total = sum(un_theta);

  %% Find the log-thetas
  this.log_theta = log((1 + un_theta) / (n_dims + un_total));

  %% Bless
  %% And add inheritance
  this = class(this, "KMDMultinomial", ...
	       KMDComponent());
endfunction
