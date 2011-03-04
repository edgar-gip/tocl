%% -*- mode: octave; -*-

%% Expectation-Maximization clustering
%% Score threshold

%% Author: Edgar Gonzalez

function [ score_threshold ] = threshold(this)

  %% Check arguments
  if nargin() ~= 1
    usage("[ score_threshold ] = @EMModel/threshold(this)");
  endif

  %% The threshold is 0.5
  score_threshold = 0.5;
endfunction
