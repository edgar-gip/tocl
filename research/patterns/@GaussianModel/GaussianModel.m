%% -*- mode: octave; -*-

%% Gaussian distribution clustering
%% Model constructor

%% Author: Edgar Gonzalez

function [ this ] = GaussianModel(k, alpha_pvar, mean, var)

  %% Check arguments
  if nargin() ~= 4
    usage("[ this ] = GaussianModel(k, alpha_pvar, mean, var)");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.k          = k;
  this.alpha_pvar = alpha_pvar; % k * 1
  this.mean       = mean;       % k * n_dims
  this.var        = var;        % k * n_dims

  %% Bless
  %% And add inheritance
  this = class(this, "GaussianModel", ...
	       Simple());
endfunction
