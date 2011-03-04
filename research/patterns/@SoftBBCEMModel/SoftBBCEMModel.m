%% -*- mode: octave; -*-

%% Soft Bregman Bubble Clustering
%% Model constructor

%% Author: Edgar Gonzalez

function [ this ] = SoftBBCEMModel(divergence, beta, k, ...
				   bg_alpha, alpha, centroids)

  %% Check arguments
  if nargin() ~= 6
    usage(cstrcat("[ this ] = SoftBBCEMModel(divergence, beta, k,", ...
		  " bg_alpha, alpha, centroids)"));
  endif

  %% This object
  this = struct();

  %% Set fields
  this.divergence = divergence;
  this.beta       = beta;
  this.k          = k;
  this.bg_alpha   = bg_alpha;
  this.alpha      = alpha;     % 1 * k
  this.centroids  = centroids; % n_dims * k

  %% Bless
  %% And add inheritance
  this = class(this, "SoftBBCEMModel", ...
	       EMModel());
endfunction
