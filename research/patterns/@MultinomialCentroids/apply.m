%% -*- mode: octave; -*-

%% Multinomial Centroid Finder
%% Find them

%% Author: Edgar Gonzalez

function [ centroids ] = apply(this, data, expec)

  %% Check arguments
  if nargin() ~= 3
    usage("[ centroids ] = @MultinomialCentroids/apply(this, data, expec)");
  endif

  %% Number of dimensions
  n_dims = size(data, 1);

  %% Active features
  active = data * expec';  % n_dims * k
  words  = sum(active, 1); % 1 * k

  %% Cluster centroids
  centroids = (active + this.data_term) / ...
              diag(words + n_dims * this.data_term);
endfunction
