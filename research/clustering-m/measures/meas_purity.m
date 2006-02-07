%% Evaluate a clustering
function [ pur ipur f1 Occ ] = meas_purity (Clusters, Labels)
  %% Sizes
  [ nElems  dummy  ] = size(Clusters);
  [ nElems2 dummy2 ] = size(Labels);

  %% Occurrency matrix
  Occ = meas_occ(Clusters, Labels);
  
  %% Purity, inverse purity, and F1
  pur  = sum(max(Occ'))  / nElems;
  ipur = sum(max(Occ)) / nElems;
  f1   = 2 * pur * ipur / (pur + ipur);

% end function