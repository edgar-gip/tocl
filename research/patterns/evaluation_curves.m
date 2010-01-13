%% Find evaluation curves

%% Author: Edgar Gonzalez

function [ curves ] = evaluation_curves(scores, truth, sizes)
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
  f1    = 2 * (prc .* roc(2,:)) ./ (prc .+ roc(2,:));

  %% Join the curves
  curves = [ total ; roc ; prc ; f1 ];

%% Local Variables:
%% mode:octave
%% End:
