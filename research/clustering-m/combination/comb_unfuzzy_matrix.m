%% Combine several clusterings into a multinomial matrix
%% May take an arbitrary number of arguments
%% But should be <clustering, nclusters> pairs
function [ CM KM Labels ] = comb_unfuzzy_matrix (rlabel, varargin)
  %% Is it empty?
  if nargin < 2
    error('There should be at least one clustering');
  end
  
  %% Number of arguments should be impair
  if mod(nargin, 2) ~= 1
    error('The number of arguments should be pair');
  end
  
  %% Turn it into a single matrix
  CM = [];
  KM = zeros((nargin - 1)/ 2, 1);

  j  = 1;
  for i = 1 : 2 : (nargin - 1)
    [TM Labels] = comb_one_unfuzzy_matrix (varargin{i}, varargin{i+1}, rlabel);
    CM          = [ CM TM ];
    KM(j)       = varargin{i+1};

    j = j + 1;
  end
  
  %% That's all

% endfunction
  
  