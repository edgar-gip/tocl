%% -*- mode: octave; -*-

%% Smooth Centroid Finder
%% Find them

%% Author: Edgar Gonzalez

function [ centroids ] = apply(this, data, expec)

  %% Check arguments
  if nargin() ~= 3
    usage("[ centroids ] = @SmoothCentroids/apply(this, data, expec)");
  endif

  %% Cluster sizes
  sizes = full(sum(expec, 2))' + this.size_term; % 1 * k

  %% Cluster centroids
  centroids = (data * expec' + this.data_term) / diag(sizes); % n_dims * k
endfunction
