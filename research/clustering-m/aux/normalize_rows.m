% Normalize a matrix by rows
function out = normalize_rows(dist)
  [r c] = size(dist);
  out   = dist ./ (sum(dist,2) * ones(1, c));
  
% end function
