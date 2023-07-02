%% Combine several clusterings into a multinomial matrix
%% May take an arbitrary number of arguments
%% But should be <clustering, nclusters> pairs
function [ CM KM ] = comb_itmedian_matrix (varargin)
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
  if dummy ~= 1
    error('Clusterings should be column vectors');
  end

  %% Number of total clusters
  kTotal = k1;

  %% Following
  for i = 3 : 2 : nargin
    %% Next element
    Clustn = varargin{i};
    kn     = varargin{i+1};

    %% Check the number of elements
    [ nelemsn dummy ] = size(Clustn);
    if dummy ~= 1
      error('Clusterings should be column vectors');
    elseif nelemsn ~= nelems
      error('All clusterings should have the same size');
    end

    %% Add to the total
    kTotal = kTotal + kn;
  end

  %% Reserve the space
  CM   = zeros(nelems, kTotal);
  KM   = zeros(nargin / 2, 1);

  %% Current pos
  off  = 1;

  %% Now again
  j = 1;
  for i = 1 : 2 : nargin
    %% Next element
    Clustn = varargin{i};
    kn     = varargin{i + 1};

    %% Add to the values
    CM(:, off : (off + kn - 1)) = ...
        ((Clustn * ones(1, kn)) == (ones(nelems, 1) * [ 0 : (kn - 1) ]));

    %% Update off
    off = off + kn;

    %% Update KM
    KM(j) = kn;
    j = j + 1;
  end

  %% Normalize
  CM = CM - ones(nelems, 1) * (sum(CM) / nelems);

% endfunction
