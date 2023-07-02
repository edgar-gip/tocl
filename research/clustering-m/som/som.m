% Self-Organizing map simple implementation
function [ Mapping W ] = som(Data, dim, iter, geometry)
  % Check parameters
  if nargin < 3 || nargin > 4
    error("som: 4 parameters required");
  end

  % Learning parameters
  alpha = 0.2;

  % Size
  [ docs terms ] = size(Data);

  % Choose grid
  if nargin == 4 && geometry == "hexa"
    % X = regular_hexa(dim);
    X = regular_grid(dim);
  else
    X = regular_grid(dim);
  end

  % Distances
  printf("Finding distances...\n");
  DistX = all_distances(X);

  % Assign weights by choosing a set of random samples
  printf("Assigning prototypes...\n");
  Idx   = floor(1.0 + rand(size(X), 1) * docs);
  W     = full(Data(Idx, :));

  % Iterate
  for it = 1 : iter
    % Iteration
    printf("Iteration %d...\n", it);

    % Linear decay of learning parameters
    it_alpha  = (1.0 - it / (iter + 1)) * alpha;
    it_radius = (1.0 - it / (iter + 1)) * sqrt(2.0);

    % Take all data, in a random order
    for idx = randperm(docs)
      % Find the bmu
      bmu = som_best_match(W, Data(idx,:));

      % Update neighbours
      W = som_update_neighbours(W, Data(idx,:), bmu, DistX,...
                                it_alpha, it_radius);
    end
  end

  % Return the mapping
  Mapping = som_mapping(W, X, Data);

% end function
