% Find the best matching unit
function bmu = som_best_match(W, Sample);
  % Find the cosine distance
  % and keep the highest one
  [ val bmu ] = max(Sample * W');

% end function
