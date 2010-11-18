%% -*- mode: octave; -*-

%% Gaussian distribution clustering
%% Model constructor

%% Author: Edgar Gonzalez

function [ this ] = GaussianModel(k, alpha_pvar, mean_stdev, stdev)

  %% Check arguments
  if nargin() ~= 4
    usage("[ this ] = GaussianModel(k, alpha_pvar, mean_stdev, stdev)");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.k          = k;
  this.alpha_pvar = alpha_pvar; % 1 * k
  this.mean_stdev = mean_stdev; % n_dims * k
  this.stdev      = stdev;      % n_dims * k

  %% Bless
  %% And add inheritance
  this = class(this, "GaussianModel", ...
	       Simple());
endfunction
