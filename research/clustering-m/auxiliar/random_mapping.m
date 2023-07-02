% Create a random mapping
function Mat = random_mapping (source_dim, target_dim, nnzrow)
    % If no sparsity defined, then create a normal matrix
    if nargin < 2
      % Give an error
      error('Source and Target Dimensions Required');

    elseif nargin == 2
      % Create a normal random matrix
      Mat = rand(source_dim, target_dim);

    else
      % Create a sparse matrix with the given number of non zeros in a row
      cols = floor(1.0 + rand (source_dim * nnzrow, 1) * target_dim);
      vals = rand (source_dim * nnzrow, 1);

      % For each row
      rows = zeros(source_dim * nnzrow, 1);
      k    = 1;
      for r = 1 : source_dim
        rows(k : (k + nnzrow - 1)) = r;
        k = k + nnzrow;
      end

      % Create the sparse matrix
      Mat = sparse(rows, cols, vals, source_dim, target_dim,...
                   source_dim * nnzrow);
    end

% end function
