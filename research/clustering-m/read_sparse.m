% Read a sparse matrix
function matrix = read_sparse (filename, normalization)
  % Read data using a C function
  if nargin == 1
    [ R C V nr nc nnz ] = cread_sparse(filename);
  elseif nargin == 2
    if strcmp(normalization, "tfidf")
      [ R C V nr nc nnz ] = cread_sparse_idf(filename);
    else
      [ R C V nr nc nnz ] = cread_sparse(filename, normalization);
    end
  else
    error('read_sparse requires one or two arguments');
  end

  % Create the sparse matrix
  matrix = sparse(R, C, V, nr, nc, nnz);
    
% end function
