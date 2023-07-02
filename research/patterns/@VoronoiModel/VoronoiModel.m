%% -*- mode: octave; -*-

%% Voronoi clustering
%% Model constructor

%% Author: Edgar Gonzalez

function [ this ] = VoronoiModel(soft_alpha, distance, centroids)

  %% Check arguments
  if nargin() ~= 3
    usage("[ this ] = VoronoiModel(soft_alpha, distance, centroids)");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.soft_alpha = soft_alpha;
  this.distance   = distance;
  this.centroids  = centroids;

  %% Bless
  %% And add inheritance
  this = class(this, "VoronoiModel", ...
               Simple());
endfunction
