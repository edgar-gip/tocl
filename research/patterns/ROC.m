% Find ROC curve

% Author: Edgar Gonzalez

function [ roc ] = ROC(scores, truth, sizes)
  % Sort scores
  [ sorted_scores, sorted_indices ] = sort(scores, 'descend');

  % Find the curve
  roc = diag(1 ./ sizes) * full(cumsum(truth(:, sorted_indices), 2));

% Local Variables:
% mode:octave
% End:
