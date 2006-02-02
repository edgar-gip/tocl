%% Initialize the EM model
function sModel = comb_mem_initialize (nclusters, FeatureSizes)
  %% Find the sizes
  [ nfeats dummy ] = size(FeatureSizes);
  if dummy ~= 1
    error('Should receive a column vector');
  end

  %% Initialize the alpha's
  Alpha = rand(nclusters, 1);
  Alpha = Alpha / sum(Alpha);

  %% Initialize the coefs for each feature
  Coefs = {};
  for i = 1 : nfeats
    TCoefs   = rand(nclusters, FeatureSizes(i));
    Coefs{i} = TCoefs ./ (sum(TCoefs, 2) * ones(1, FeatureSizes(i)));
  end
  
  %% Set the struct
  sModel.alpha = Alpha;
  sModel.coefs = Coefs;

% end function
