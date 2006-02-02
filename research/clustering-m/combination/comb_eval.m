%% Evaluate a clustering
function [ pur ipur f1 Occ ] = comb_eval (Clusters, Labels)
  %% Sizes
  [ nElems  dummy  ] = size(Clusters);
  [ nElems2 dummy2 ] = size(Labels);

  %% Check column vectors
  if dummy ~= 1 || dummy2 ~= 1
    error('Clusters and Labels must be column vectors');
  end

  %% Check matching rows
  if nElems ~= nElems2
    error('Clusters and Labels sizes should match');
  end

  %% Add 1
  Clusters = Clusters + 1;
  Labels   = Labels + 1;

  %% Sizes
  nClust = max(Clusters);
  nLabls = max(Labels);

  %% Occurrency matrix
  Occ = zeros(nLabls, nClust);

  %% Account for every pair
  for i = 1 : nElems
    Occ(Labels(i), Clusters(i)) = Occ(Labels(i), Clusters(i)) + 1;
  end

  %% Purity, inverse purity, and F1
  pur  = sum(max(Occ))  / nElems;
  ipur = sum(max(Occ')) / nElems;
  f1   = 2 * pur * ipur / (pur + ipur);

% end function