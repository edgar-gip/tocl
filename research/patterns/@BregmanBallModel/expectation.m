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
  divs = apply(this.divergence, this.centroids, data);

  %% Only one cluster?
  if this.k == 1
    %% Keep those within
    on   = find(divs <= this.radius);
    n_on = length(on);

    %% Expectation
    expec = sparse(ones(1, n_on), on, ones(1, n_on), 1, n_samples);

  else %% this.k > 1
    %% Select the closest cluster
    [ min_divs, min_indices ] = min(divs);

    %% Keep those within
    on   = find(min_divs <= this.radius);
    n_on = length(on);

    %% Expectation
    expec = sparse(min_indices(on), on, ones(1, n_on), this.k, n_samples);
  endif

  %% Log-likelihood is not considered here
  log_like = nan;
endfunction
