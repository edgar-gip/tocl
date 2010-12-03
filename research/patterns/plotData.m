%% -*- mode: octave; -*-

%% Plot data

%% Author: Edgar Gonzàlez i Pellicer


%% Octopus
pkg load octopus


%% Input
cmd_args = argv();

%% First is -p (parallel?)
parallel = false();
if length(cmd_args) > 0 && strcmp(cmd_args{1}, "-p")
  parallel = true();
  cmd_args = { cmd_args{2:length(cmd_args)} };
endif

%% Arguments
if length(cmd_args) < 1
  error("Usage: plotData.m [-p] <input> [<input>...]");
endif

%% Not parallel?
if ~parallel
  one_fig = figure();
endif

%% For each one
for input = cmd_args
  %% Load
  try
    load(input{1}, "data", "truth");
  catch
    error("Cannot load data from '%s': %s", input{1}, lasterr());
  end_try_catch

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
  if parallel
    one_fig = figure();
  endif
  figure(one_fig, "name", input{1});

  %% Plot
  if n_dims == 2
    plot(plots{:});
  else %% n_dims == 3
    plot3(plots{:});
  endif

  %% Pause
  if ~parallel
    pause();
  endif
endfor

%% Pause
if parallel
  pause();
endif
