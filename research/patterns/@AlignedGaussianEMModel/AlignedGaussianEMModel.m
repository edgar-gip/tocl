%% -*- mode: octave; -*-

%% Gaussian distribution EM clustering
%% Axis-aligned variance version
%% Model constructor

%% Author: Edgar Gonzalez

function [ this ] = AlignedGaussianEMModel(k, alpha_norm, mu, isigma)

  %% Check arguments
  if nargin() ~= 4
    usage("[ this ] = AlignedGaussianEMModel(k, alpha_norm, mu, isigma)");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.k          = k;
  this.alpha_norm = alpha_norm; % 1 * k
  this.mu         = mu;         % n_dims * k
  this.isigma     = isigma;     % n_dims * k

  %% Bless
  %% And add inheritance
  this = class(this, "AlignedGaussianEMModel", ...
	       Simple());
endfunction
