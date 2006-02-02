%% Create a good clustering by combining random partitions
function Clustering = weak_random_combination (nClusters, nWeaks, Data)
  %% Accumulator
  target = {};

  %% Just call weaks and let it do it
  for i = 1 : nWeaks
    WC = weak_random_projection(nClusters, Data);
    target{2 * i - 1} = WC;
    target{2 * i}     = nClusters;
    i = i + 2;
  end

  %% Combine
  Clustering = comb_combine_mem(nClusters, target{:});

% end function