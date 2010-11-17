%% -*- mode: octave; -*-

%% Bregman Ball clustering
%% Score threshold

%% Author: Edgar Gonzalez

function [ score_threshold ] = score(this, data)

  %% Check arguments
  if nargin() ~= 1
    usage("[ score_threshold ] = @BregmanBallModel/threshold(this)");
  endif

  %% The threshold is the negated radius
  score_threshold = -this.radius;
endfunction
