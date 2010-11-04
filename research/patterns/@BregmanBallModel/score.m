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
  %% Use negated divergence matrix as score
  scores = -apply(this.divergence, this.centroid, data);
endfunction
