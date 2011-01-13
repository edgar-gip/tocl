%% -*- mode: octave; -*-

%% k-Means clustering
%% Model constructor

%% Author: Edgar Gonzalez

function [ this ] = KMeansModel(divergence, centroids)

  %% Check arguments
  if nargin() ~= 2
    usage("[ this ] = KMeansModel(divergence, centroids)");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.divergence = divergence;
  this.centroids  = centroids;

  %% Extra fields
  [ n_dims, k ] = size(centroids);
  this.k        = k;

  %% Bless
  %% And add inheritance
  this = class(this, "KMeansModel", ...
	       Simple());
endfunction
