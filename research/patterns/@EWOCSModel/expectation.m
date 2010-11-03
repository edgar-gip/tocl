%% -*- mode: octave; -*-

%% Ensemble Weak One-Class Scoring
%% Expectation

%% Author: Edgar Gonzalez

function [ expec, log_like ] = expectation(this, data)

  %% Find the scores
  [ scores, log_like ] = score(this, data);

  %% Interpolate them
  expec = apply(this.interpolator, scores);
endfunction
