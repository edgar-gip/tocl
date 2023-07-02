%% Get the sharing matrix of a clustering
%% Do point i and j belong to the same cluster?
function M = comb_sharing_matrix (Clustering)
  %% Check argument
  [ nelems dummy ] = size(Clustering);
  if dummy ~= 1
    error('Clustering should be a column vector');
  end

  %% Create the matrix
  M = ((Clustering * ones(1, nelems) ==
        ones(nelems, 1) * Clustering'));

% end function
