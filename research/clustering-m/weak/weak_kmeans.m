%% Cluster using a kmeans algorithm
%% Code taken and adapted from the SOMToolBox
function Clustering = weak_kmeans (nClusters, Data)
  %% Find dimensions
  [ nData nFeats ] = size(Data);

  %% Choose random points as starting centroids
  Start     = randperm(nData)(1:nClusters);
  Centroids = Data(Start,:);

  %% Find responsabilities
  [ Dummy Resp ] = min((( ones(nClusters, 1) * sum((Data .^ 2)', 1))' ...
			+ ones(nData, 1) * sum((Centroids .^ 2)', 1) ...
			- 2 .* (Data * (Centroids')))');
  
  %% Loop
  do
    %% Save Responsabilites
    OResp = Resp;

    %% Update centroids
    for c = 1 : nClusters
      Idx = find(Resp == c);
      n   = length(Idx);
      if n
	Centroids(c, :) = sum(Data(Idx, :)) / n;
      end
    end

    %% Find Responsabilites
    [ Dummy Resp ] = min((( ones(nClusters, 1) * sum((Data .^ 2)', 1))' ...
			  + ones(nData, 1) * sum((Centroids .^ 2)', 1) ...
			  - 2 .* (Data * (Centroids')))');

    %% Changes
    changes = sum(Resp ~= OResp);

  until (changes == 0)

  %% Return responsabilities (based on 0)
  Clustering = Resp' - 1;

% end function