%% -*- mode: octave; -*-

%% Ensemble Weak One-Class Scoring
%% Expectation

%% Author: Edgar Gonzalez

function [ expec, log_like, scores ] = expectation(this, data)

  %% Check arguments
  if nargin() ~= 2
    usage("[ expec, log_like, scores ] = @EWOCSModel/expectation(this, data)");
  endif

  %% Find the scores
  scores = score(this, data);

  %% Interpolate them
  expec = apply(this.inter_model, scores);

  %% Log-like is not considered here
  log_like = nan;
endfunction
