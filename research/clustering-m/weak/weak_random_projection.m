%% Create a weak random projection clustering
function Clustering = weak_random_projection (nClusters, Data)
  %% Find dimensions
  [ nData nFeats ] = size(Data);

  %% Find projection vector to 1D
  Projection = rand(nFeats, 1);

  %% Find projected data
  pData = Data * Projection;

  %% K-Means
  Clustering = weak_kmeans(nClusters, pData);

% end function
