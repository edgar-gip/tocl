%% -*- mode: octave; -*-

%% Voronoi clustering
%% Model constructor

%% Author: Edgar Gonzalez

function [ this ] = VoronoiModel(soft_alpha, distance, centroids)

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
