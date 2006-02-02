%% Combine several clusterings into a multinomial matrix
%% May take an arbitrary number of arguments
%% But should be <clustering, nclusters> pairs
function [ CM KM ] = comb_multinomial_matrix (varargin)
  %% Is it empty?
  if nargin == 0
    error('There should be at least one clustering');
  end
  
  %% Number of arguments should be pair
  if mod(nargin, 2) ~= 0
    error('The number of arguments should be pair');
  end
  
  %% Size
  [ nelems dummy ] = size(varargin{1});

  %% Turn it into a single matrix
  CM = zeros(nelems, nargin / 2);
  KM = zeros(nargin / 2, 1);

  j  = 1;
  for i = 1 : 2 : nargin
    CM(:,j) = varargin{i};
    KM(j)   = varargin{i+1};

    j = j + 1;
  end
  
  %% That's all

% endfunction
  
  
