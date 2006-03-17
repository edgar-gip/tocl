%% Upgrade EM model to weighted
function sModel = comb_mem_addweight (inModel, Weights)
  %% Check the weights
  [ nweigs dummy ] = size(Weights);
  if dummy ~= 1
    error('Should receive a column vector');
  end
  
  %% Set the struct
  sModel         = inModel;
  sModel.kind    = 2;
  sModel.weights = Weights;

% end function
