%% Combine several clusterings into a binary matrix
%% May take an arbitrary number of arguments
%% But should be <clustering, nclusters> pairs
function [ CM KM ] = comb_binary_matrix (varargin)
  %% Is it empty?
  if nargin == 0
    error('There should be at least one clustering');
  end

  %% Number of arguments should be pair
  if mod(nargin, 2) ~= 0
    error('The number of arguments should be pair');
  end

  %% First element
  Clust1 = varargin{1};
  k1     = varargin{2};

  %% Number of elements
  [ nelems dummy ] = size(Clust1);

  %% Number of total clusters
  kTotal = k1;
  nTotal = nelems;

  %% Following
  for i = 3 : 2 : nargin
    %% Next element
    Clustn = varargin{i};
    kn     = varargin{i+1};

    %% Check the number of elements
    [ nelemsn dummy ] = size(Clustn);
    if nelemsn ~= nelems
      error('All clusterings should have the same size');
    end

    %% Add to the total
    kTotal = kTotal + kn;
    nTotal = nTotal + nelemsn;
  end

  %% Reserve the space
  Rows = zeros(nTotal, 1);
  Cols = zeros(nTotal, 1);

  %% Normalized (so every has module 1)
  Vals = ones (nTotal, 1) / sqrt(nargin / 2);

  %% KM
  KM   = zeros(nargin / 2, 1);

  %% Current pos
  pos  = 1;
  off  = 1;

  %% Now again
  j = 1;
  for i = 1 : 2 : nargin
    %% Next element
    Clustn = varargin{i};
    kn     = varargin{i + 1};

    %% Add to the values
    Rows(pos : (pos + nelems - 1)) = 1 : nelems;
    Cols(pos : (pos + nelems - 1)) = Clustn + off;

    %% Update pos
    pos = pos + nelems;
    off = off + kn;

    %% Update KM
    KM(j) = kn;
    j = j + 1;
  end

  %% Turn it into a sparse matrix
  CM = sparse(Rows, Cols, Vals, nelems, kTotal, nTotal);

% endfunction
