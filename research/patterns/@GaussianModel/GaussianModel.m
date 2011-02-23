%% -*- mode: octave; -*-

%% Gaussian distribution clustering
%% Model constructor

%% Author: Edgar Gonzalez

function [ this ] = GaussianModel(k, alpha_norm, mu, isigma)

  %% Check arguments
  if nargin() ~= 4
    usage("[ this ] = GaussianModel(k, alpha_norm, mu, isigma)");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.k          = k;
  this.alpha_norm = alpha_norm; % 1 * k
  this.mu         = mu;         % n_dims * k
  this.isigma     = isigma;     % n_dims * n_dims * k

  %% Bless
  %% And add inheritance
  this = class(this, "GaussianModel", ...
	       Simple());
endfunction
