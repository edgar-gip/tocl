%% Return the combination of several clusters
function Combination = comb_combine_mem (nclusters, varargin)
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
  [ CM KM ] = comb_multinomial_matrix (target{:});
  
  %% Random starting model
  model = comb_mem_initialize(nclusters, KM);

  %% Initial expectation
  Exp = comb_mem_expectation(model, CM);

  %% Maximization
  do
    OExp  = Exp;
    model = comb_mem_maximization(CM, KM, Exp);
    Exp   = comb_mem_expectation(model, CM);
    delta = sum(sum((Exp - OExp) .^ 2));
  until (delta < 1e-10)

  %% Result
  [ Max Idx ] = max(Exp');
  Combination = Idx' - 1;

% end function


