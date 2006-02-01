% The cosine distance between two vectors
function cos = som_cosine_distance(A, B)
  % Simply dot product
  cos =  1.0 - A * B';

% end function