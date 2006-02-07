%% Return the combination of several clusters
function Combination = comb_combine_itmedian (nclusters, varargin)
  %% At least one parameter
  if nargin == 1
    error('Must give at least a clustering');
  end

  %% Check type of arguments
  target = {}; i = 1; t = 1;
  while i <= nargin - 1
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
  
  %% Create the multinomial matrix
  CM = comb_itmedian_matrix (target{:});
  
  %% Find k means clustering
  Combination = weak_kmeans(nclusters, CM);

% end function


