%% -*- mode: octave; -*-

%% Bregman Ball clustering
%% Scoring function (divergence)

%% Author: Edgar Gonzalez

function [ scores ] = score(this, data)

  %% Check arguments
  if nargin() ~= 2
    usage("[ scores ] = @BregmanBallModel/score(this, data)");
  endif

  %% Find the divergence matrix
  divs = apply(this.divergence, this.centroids, data);

  %% Only one cluster?
  if this.k == 1
    %% Use negated divergence matrix as score
    scores = -divs;

  else %% this.k > 1
    %% Select the closest cluster
    min_divs = min(divs);

    %% Use negated minimal divergences as score
    scores = -min_divs;
  endif
endfunction
