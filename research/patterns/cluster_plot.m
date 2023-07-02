%% -*- mode: octave; -*-

%% Plot data

%% Author: Edgar Gonzàlez i Pellicer


%% (Regular) cluster plot
function cluster_plot(data, truth, name, fig)
  %% Size
  [ n_dims, n_data ] = size(data);
  k = max(truth);

  %% Check
  if n_dims ~= 2 && n_dims ~= 3
    error("Can only plot 2 or 3-dimensional data");
  endif

  %% Plots
  plots = {};

  %% For each cl
  for cl = 1 : k
    %% Elements
    cluster = find(truth == cl);

    %% Add their data
    if n_dims == 2
      plots = cell_push(plots, ...
                        data(1, cluster), data(2, cluster), "x");
    else %% n_dims == 3
      plots = cell_push(plots, ...
                        data(1, cluster), data(2, cluster), ...
                        data(3, cluster), "x");
    endif
  endfor

  %% Figure
  if isempty(fig)
    fig = figure();
  endif

  %% Name
  if ~isempty(name)
    figure(fig, "name", name);
  endif

  %% Plot
  if n_dims == 2
    plot(plots{:});
  else %% n_dims == 3
    plot3(plots{:});
  endif
endfunction
