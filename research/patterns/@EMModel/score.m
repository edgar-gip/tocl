%% -*- mode: octave; -*-

%% Expectation-Maximization clustering
%% Scoring function

%% Author: Edgar Gonzalez

function [ scores ] = score(this, data)

  %% Check arguments
  if nargin() ~= 2
    usage("[ scores ] = @EMModel/score(this, data)");
  endif

  %% Find the expectation, and sum it
  scores = sum(expectation(this, data), 1);
endfunction
