% Find all distances
function DistX = all_distances(X)
  %% Size
  [ n dim ] = size(X);

  %% At the beginning, empty
  DistX = zeros(n, n);
  for i = 1 : (n - 1)
    inds = [(i + 1) : n];
    Dco  = (X(inds, :) - X(ones(n - i, 1) * i,:))';
    Dco2 = sqrt(sum(Dco .^ 2));

    DistX(i, inds) = Dco2;
    DistX(inds, i) = Dco2';
  end

% end function
