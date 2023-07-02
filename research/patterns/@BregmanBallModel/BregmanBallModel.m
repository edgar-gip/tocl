%% -*- mode: octave; -*-

%% Bregman Ball clustering
%% Model constructor

%% Author: Edgar Gonzalez

function [ this ] = BregmanBallModel(divergence, centroids, radius)

  %% Check arguments
  if nargin() ~= 3
    usage("[ this ] = BregmanBallModel(divergence, centroids, radius)");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.divergence = divergence;
  this.centroids  = centroids;
  this.radius     = radius;

  %% Extra fields
  [ n_dims, k ] = size(centroids);
  this.k        = k;

  %% Bless
  %% And add inheritance
  this = class(this, "BregmanBallModel", ...
               Simple());
endfunction
