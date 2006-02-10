%% Return the combination of several clusters
function Eigen = comb_combine_binary (varargin)
  %% At least one parameter
  if nargin < 1
    error('Must give at least a clustering');
  end

  %% Check type of arguments
  target = {}; i = 1; t = 1;
  while i <= nargin
    %% Type of current
    curType = typeinfo(varargin{i});
    if strcmp(curType, 'string')
      %% A file, load it
      [ C k ] = read_clustering(varargin{i});
      target{t}   = C;
      target{t+1} = k;
      i = i + 1;
      t = t + 2;

    else
      %% A matrix
      target{t}   = varargin{i};
      target{t+1} = varargin{i+1};
      i = i + 2;
      t = t + 2;
    end
  end
  
  %% Create the binary matrix
  CM = comb_binary_matrix (target{:});
  
  %% Find the eigenvalues
  Eigen = eig(CM * CM');

% end function