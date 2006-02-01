% Return the mapping finally produced by SOM
function Mapping = som_mapping(W, X, Data) 
  % Find the sizes
  [ docs terms ] = size(Data);
  [ points dim ] = size(X);
  
  % Find the best matching unit for each sample
  Mapping = zeros(docs, dim);
  for i = 1 : docs
    Mapping(i, :) = X(som_best_match(W, Data(i, :)), :);
  end

% end function
