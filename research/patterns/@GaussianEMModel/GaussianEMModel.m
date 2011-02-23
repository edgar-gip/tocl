%% -*- mode: octave; -*-

%% Gaussian distribution EM clustering
%% Model constructor

%% Author: Edgar Gonzalez

function [ this ] = GaussianEMModel(k, alpha_norm, mu, isigma)

  %% Check arguments
  if nargin() ~= 4
    usage("[ this ] = GaussianEMModel(k, alpha_norm, mu, isigma)");
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
  this = class(this, "GaussianEMModel", ...
	       Simple());
endfunction
