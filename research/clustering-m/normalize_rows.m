% Normalize a matrix by rows
function out = normalize_rows(dist)
  out   = dist;
  [r c] = size(dist);
  for i = 1:r
    s = sum(dist(i,:));
    if (s ~= 0.0)
      out(i,:) = dist(i,:) / s;
    end
  end
  
% end function
