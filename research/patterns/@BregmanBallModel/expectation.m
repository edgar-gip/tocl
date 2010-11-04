%% -*- mode: octave; -*-

%% Bregman Ball clustering
%% Expectation

%% Author: Edgar Gonzalez

function [ expec, log_like ] = expectation(this, data)

  %% Check arguments
  if nargin() ~= 2
    usage("[ expec, log_like ] = @BregmanBallModel/expectation(this, data)");
  endif

  %% Number of samples
  [ n_feats, n_samples ] = size(data);

  %% Find the divergence matrix
  divs = apply(this.divergence, this.centroid, data);

  %% Keep those within
  cluster   = find(divs <= this.radius);
  n_cluster = length(cluster);

  %% Expectation
  expec = sparse(ones(1, n_cluster), cluster, ones(1, n_cluster), ...
		 1, n_samples);

  %% Log-likelihood is not considered here
  log_like = nan;
endfunction
