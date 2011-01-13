%% -*- mode: octave; -*-

%% k-Means clustering
%% Centroids accessor

%% Author: Edgar Gonzalez

function [ cs ] = centroids(this);

  %% Check arguments
  if nargin() ~= 1
    usage("[ cs ] = @KMeansModel/centroids(this)");
  endif

  %% Return the centroids
  cs = this.centroids;
endfunction

