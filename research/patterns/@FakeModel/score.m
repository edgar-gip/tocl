%% -*- mode: octave; -*-

%% Fake model (which stores a constant score vector)
%% Scoring function

%% Author: Edgar Gonzalez

function [ scores ] = score(this, data)

  %% Check arguments
  if nargin() ~= 2
    usage("[ scores ] = @FakeModel/score(this, data)");
  endif

  %% Check the size is the same
  if size(data, 2) ~= length(this.scores)
    error("Data and score vector size mismatch");
  endif

  %% Return
  scores = this.scores;
endfunction
