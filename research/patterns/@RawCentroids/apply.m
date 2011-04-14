%% -*- mode: octave; -*-

%% Raw Centroid Finder
%% Find them

%% Author: Edgar Gonzalez

function [ centroids ] = apply(this, data, expec)

  %% Check arguments
  if nargin() ~= 3
    usage("[ centroids ] = @RawCentroids/apply(this, data, expec)");
  endif

  %% Cluster sizes
  sizes = full(sum(expec, 2))'; % 1 * k

  %% Cluster centroids
  centroids = (data * expec') / diag(sizes); % n_dims * k
endfunction
