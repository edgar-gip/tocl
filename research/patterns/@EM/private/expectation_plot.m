%% -*- mode: octave; -*-

%% Plot expectation

%% Author: Edgar Gonzàlez i Pellicer


%% Expectation plot
function expectation_plot(data, model, expec = [], add_bg = false(), ...
                          fig = [], opts = struct());
  %% Options
  n_grid = getfielddef(opts, "n_grid", 20);

  %% Check dimensions
  [ n_dims, n_data ] = size(data);
  if n_dims ~= 2
    error("data must be 2-dimensional");
  endif

  %% The expectation is given?
  if isempty(expec)
    expec = expectation(model, data);
  endif

  %% Number of clusters
  [ k, n_data ] = size(expec);

  %% Data range
  max_data = max(data, [], 2);
  min_data = min(data, [], 2);
  range    = max_data - min_data;

  %% Grid
  grid   = repmat(min_data, 1, n_grid) + ...
           (range / (n_grid - 1)) * (0 : (n_grid - 1));
  x_grid = grid(1, :);
  y_grid = grid(2, :);

  %% Now, cross them
  [ xx, yy ] = meshgrid(x_grid, y_grid);

  %% Reshape them
  grid_data = [ reshape(xx, 1, n_grid * n_grid) ; ...
                reshape(yy, 1, n_grid * n_grid) ];

  %% Find its expectation
  grid_expec = expectation(model, grid_data);

  %% Harden data expectation
  [ hard_expec, hard_class ] = harden_expectation(expec, add_bg);

  %% Figure
  if isempty(fig)
    %% New figure
    figure();

  elseif ischar(fig)
    %% New figure with a name
    figure("name", fig);

  else
    %% Reuse previous figure
    figure(fig);
  endif

  %% Hold them
  newplot();
  hold("on");

  %% Background cluster
  if add_bg
    bg_idx = find(hard_class == 1);
    if ~isempty(bg_idx)
      plot(data(1, bg_idx), data(2, bg_idx), "0*");
    endif
  endif

  %% For each cluster
  for c = 1 : k
    %% Find the points (1- or 2-based according to wether there was bg)
    cl_idx = find(hard_class == add_bg + c);
    if ~isempty(cl_idx)
      plot(data(1, cl_idx), data(2, cl_idx), sprintf("%d*", 1 + mod(c - 1, 5)));
    endif

    %% Find the contour
    cl_expec = reshape(grid_expec(c, :), n_grid, n_grid);
    contour(x_grid, y_grid, cl_expec, 4);
  endfor

  %% No more hold
  hold("off");
endfunction
