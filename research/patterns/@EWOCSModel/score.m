%% -*- mode: octave; -*-

%% Ensemble Weak One-Class Scoring
%% Scoring function

function [ scores ] = score(this, data)

  %% Data must be given
  if nargin() ~= 2
    usage("[ scores ] = @EWOCSModel/score(this, data)");
  endif

  %% Ensemble size
  ensemble_size = length(this.models);

  %% Size
  [ n_feats, n_samples ] = size(data);

  %% Scores
  scores = zeros(1, n_samples);

  %% For each element in the ensemble
  for i = 1 : ensemble_size

    %% Find the expectation
    ind_expec = expectation(this.models{i}, data);

    %% Add scores
    scores += this.cluster_scores{i} * ind_expec;
  endfor
endfunction
