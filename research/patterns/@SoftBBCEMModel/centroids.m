%% -*- mode: octave; -*-

%% Soft Bregman Bubble Clustering
%% Centroids accessor

%% Author: Edgar Gonzalez

function [ cs ] = centroids(this);

  %% Check arguments
  if nargin() ~= 1
    usage("[ cs ] = @SoftBBCEMModel/centroids(this)");
  endif

  %% Return the centroids
  cs = this.centroids;
endfunction
