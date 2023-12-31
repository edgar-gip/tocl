%% -*- mode: octave; -*-

%% Ensemble Weak One-Class Scoring
%% Scoring function

%% Author: Edgar Gonzalez

function [ scores ] = score(this, data)

  %% Check arguments
  if nargin() ~= 2
    usage("[ scores ] = @EWOCSModel/score(this, data)");
  endif

  %% Ensemble size
  ensemble_size = length(this.models);

  %% Size
  [ n_dims, n_samples ] = size(data);

  %% Scores
  scores = zeros(1, n_samples);

  %% For each element in the ensemble
  for i = 1 : ensemble_size

    %% Find the expectation
    ind_expec = expectation(this.models{i}, data);

    %% Add scores
    scores += this.cluster_scores{i} * ind_expec;
  endfor

  %% Divide scores
  scores ./= ensemble_size;
endfunction
