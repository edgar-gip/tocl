%% Return the combination of several clusters
function [ Clustering Labels ] = comb_combine_unfuzzy (Nclusters, rlabel, varargin)
  %% At least two parameters
  if nargin < 3
    error('Must give at least a clustering');
  end

  %% Check type of arguments
  target = {}; i = 1; t = 1;
  while i <= nargin - 2
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

  %% Create the unfuzzy matrix
  [ CM KM Labels ] = comb_unfuzzy_matrix (rlabel, target{:});

  %% Normalize it
  CM = normalize_rows(CM);

  %% Automatically find sizes?
  if Nclusters == 0
    low  = max(2, floor(0.80 * min(KM)));
    high = ceil(1.20 * max(KM));
    Nclusters = [ low:high ]';
  end

  %% Find the output
  Clustering = weak_kmeans(KM(1), CM);

% end function
