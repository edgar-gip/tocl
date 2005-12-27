% Normalize a matrix by columns
function out = normalize_cols(dist)
  out   = dist;
  [r c] = size(dist);
  for i = 1:c
    s = sum(dist(:,i));
    if (s ~= 0.0)
      out(:,i) = dist(:,i) / s;
    end
  end
    
