%% Upgrade EM model to weighted
function sModel = comb_mem_addweight (inModel, Weights)
  %% Check the weights
  [ nweigs dummy ] = size(Weights);
  if dummy ~= 1
    error('Should receive a column vector');
  end
  
  %% Check sum of weights
  if sum(Weights) ~= nweigs
    error('Weights should sum up to the number of features');
  end

  %% Set the struct
  sModel         = inModel;
  sModel.kind    = 2;
  sModel.weights = Weights;

% end function
