%% -*- mode: octave; -*-

%% Bregman Divergence EM-like clustering
%% Model constructor

%% Author: Edgar Gonzalez

function [ this ] = BregmanEMModel(divergence, beta, k, alpha, centroids)

  %% Check arguments
  if nargin() ~= 5
    usage("[ this ] = BregmanEMModel(divergence, beta, k, alpha, centroids)");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.divergence = divergence;
  this.beta       = beta;
  this.k          = k;
  this.alpha      = alpha;     % 1 * k
  this.centroids  = centroids; % n_dims * k

  %% Bless
  %% And add inheritance
  this = class(this, "BregmanEMModel", ...
	       Simple());
endfunction
