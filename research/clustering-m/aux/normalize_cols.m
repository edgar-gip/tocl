% Normalize a matrix by columns
function out = normalize_cols(dist)
  [r c] = size(dist);
  out   = dist ./ (ones(r, 1) * sum(dist));

% end function
