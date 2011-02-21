%% -*- mode: octave; -*-

%% Plot multidimensional data pairwiselly

%% Author: Edgar Gonzàlez i Pellicer


%% Pairwise cluster plot
function pairwise_cluster_plot(data, truth, name = [], fig = [])
  %% Size
  [ n_dims, n_data ] = size(data);
  k = max(truth);

  %% Figure
  if isempty(fig)
    fig = figure();
  endif

  %% Name
  if ~isempty(name)
    figure(fig, "name", name);
  endif

  %% For each pair of dimensions
  for d1 = 1 : n_dims
    for d2 = d1 + 1 : n_dims
      %% Plots
      plots = {};

      %% For each cl
      for cl = 1 : k
	%% Elements
	cluster = find(truth == cl);

	%% Add their data
	plots = cell_push(plots, ...
			  data(d1, cluster), data(d2, cluster), ...
			  sprintf("x%d", mod(cl - 1, 6)));
      endfor

      %% Subplot
      subplot(n_dims - 1, n_dims - 1, (d2 - 2) * (n_dims - 1) + d1);

      %% Plot
      plot(plots{:});
    endfor
  endfor
endfunction
