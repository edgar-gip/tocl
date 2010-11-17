%% -*- mode: octave; -*-

%% Ensemble Weak One-Class Scoring
%% Score threshold

%% Author: Edgar Gonzalez

function [ score_threshold ] = threshold(this)

  %% Check arguments
  if nargin() ~= 1
    usage("[ scores ] = @EWOCSModel/threshold(this)");
  endif

  %% It is the inverse of 0.5 by the interpolation model
  score_threshold = inverse(this.inter_model, 0.5);
endfunction
