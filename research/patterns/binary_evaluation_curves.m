%% -*- mode: octave; -*-

%% Find binary evaluation curves
%% Output: <total> <neg_rec> <rec> <prc> <f1> <score>

%% Author: Edgar Gonzalez

function [ curves ] = binary_evaluation_curves(scores, truth, sizes)
  %% Sort scores
  [ sorted_scores, sorted_indices ] = sort(scores, 'descend');

  %% Accumulated
  accum = full(cumsum(truth(:, sorted_indices), 2));

  %% Total
  total = sum(accum, 1);

  %% Find the ROC curve
  roc   = diag(1 ./ sizes) * accum;

  %% Find the Precision curve
  prc   = accum(2,:) ./ total;

  %% F1
  f1            = 2 * (prc .* roc(2,:)) ./ (prc .+ roc(2,:));
  f1(isnan(f1)) = 0.0;

  %% Join the curves
  curves = [ total ; roc ; prc ; f1 ; sorted_scores ];
endfunction
