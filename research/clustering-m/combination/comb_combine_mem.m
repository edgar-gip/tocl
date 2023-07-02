%% Return the combination of several clusters
function [ Lls Sizes Models ] = comb_combine_mem (Nclusters, varargin)
  %% At least two parameters
  if nargin < 2
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

  %% Delta threshold
  [ elems dummy ] = size(CM);
  deltaTh         = 1e-8 * elems;

  %% Automatically find sizes?
  if Nclusters == 0
    low  = max(2, floor(0.80 * min(KM)));
    high = ceil(1.20 * max(KM));
    Nclusters = [ low:high ]';
  end

  %% For each ncluster in Nclusters
  [ tests dummy ] = size(Nclusters);

  %% Save state
  Lls    = zeros(tests, 1);
  Models = {};

  %% Try
  for i = 1:tests
    %% Local best
    localBestLl = -1e100;
    avgLl       = 0.0;

    for j = 1:5
      %% Random starting model
      model = comb_mem_initialize(Nclusters(i), KM);

      %% Initial expectation
      Exp = comb_mem_expectation(model, CM);

      %% Maximization
      do
        OExp  = Exp;
        model = comb_mem_maximization(CM, KM, Exp);
        Exp   = comb_mem_expectation(model, CM);
        delta = sum(sum((Exp - OExp) .^ 2));
      until (delta < deltaTh)

      %% Result
      [ Max Idx ] = max(Exp');
      Combi = Idx' - 1;

      %% Log-likelihood
      ll = comb_mem_loglike(model, CM);

      %% Average
      avgLl = avgLl + ll;

      %% Is it the local best?
      if ll > localBestLl
        localBest   = Combi;
        localBestLl = ll;
      end
    end

    %% Average
    avgLl = avgLl / 5;

    %% Add it
    Lls(i)    = avgLl;
    Models{i} = localBest;
  end

  %% Sizes
  Sizes = Nclusters;

% end function
