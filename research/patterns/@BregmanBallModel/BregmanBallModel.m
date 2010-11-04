%% -*- mode: octave; -*-

%% Bregman Ball clustering
%% Model constructor

%% Author: Edgar Gonzalez

function [ this ] = BregmanBallModel(divergence, centroid, radius)

  %% Check arguments
  if nargin() ~= 3
    usage("[ this ] = BregmanBallModel(divergence, centroid, radius)");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.divergence = divergence;
  this.centroid   = centroid;
  this.radius     = radius;

  %% Bless
  %% And add inheritance
  this = class(this, "BregmanBallModel", ...
	       Simple());
endfunction
