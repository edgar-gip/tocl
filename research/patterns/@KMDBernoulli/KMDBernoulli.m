%% -*- mode: octave; -*-

%% k-Minority Detection

%% Bernoulli Component Constructor

%% Author: Edgar Gonzalez

function [ this ] = KMDBernoulli(first, un_theta)

  %% Check arguments
  if ~any(nargin() == [ 1, 2 ])
    usage("[ this ] = KMDBernoulli(data | n_data, un_theta)");
  endif

  %% Data was given?
  if nargin() == 1
    %% Size
    [ n_dims, n_data ] = size(first);

    %% Find the unnormalized thetas
    un_theta = full(sum(first > 0, 2))';

  else
    %% Fetch
    n_data = first;
  endif

  %% This object
  this = struct();

  %% Set fields
  this.n_data   = n_data;
  this.un_theta = un_theta;

  %% p(x) and p(~x)
  p_x      = (this.un_theta + 1) / (this.n_data + 2);
  log_p_x  = log(p_x);
  log_p_nx = log(1 - p_x);

  %% Theta and ctheta
  this.clog_theta  = log_p_x - log_p_nx;
  this.log_ctheta = sum(log_p_nx);

  %% Bless
  %% And add inheritance
  this = class(this, "KMDBernoulli", ...
               KMDComponent());
endfunction
