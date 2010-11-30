%% -*- mode: octave; -*-

%% Plot data

%% Author: Edgar Gonzàlez i Pellicer


%% Octopus
pkg load octopus


%% Input
cmd_args = argv();
if length(cmd_args) ~= 1
  error("Usage: plotData.m <input>");
endif
input = cmd_args{1};

%% Load
try
  load(input, "data", "truth");
catch
  error("Cannot load data from '%s': %s", input, lasterr());
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

%% Plot
if n_dims == 2
  plot(plots{:});
else %% n_dims == 3
  plot3(plots{:});
endif

%% Pause
pause();
