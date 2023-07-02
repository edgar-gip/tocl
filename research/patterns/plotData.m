%% -*- mode: octave; -*-

%% Plot data

%% Author: Edgar Gonzàlez i Pellicer


%% Octopus
pkg load octopus

%% Options
def_opts          = struct();
def_opts.parallel = false();
def_opts.pairwise = false();

%% Parse options
[ cmd_args, cmd_opts ] = ...
    get_options(def_opts, ...
                "parallel!", "parallel", ...
                "pairwise!", "pairwise");

%% Arguments
if length(cmd_args) < 1
  error("Usage: plotData.m [--parallel] [--pairwise] <input> [<input>...]");
endif

%% Not parallel?
if ~cmd_opts.parallel
  one_fig = figure();
else
  one_fig = [];
endif

%% For each one
for input = cmd_args
  %% Load
  try
    load(input{1}, "data", "truth");
  catch
    error("Cannot load data from '%s': %s", input{1}, lasterr());
  end_try_catch

  %% Pairwise?
  if cmd_opts.pairwise
    pairwise_cluster_plot(data, truth, input{1}, one_fig);
  else
    cluster_plot(data, truth, input{1}, one_fig);
  endif

  %% Pause
  if ~cmd_opts.parallel
    pause();
  endif
endfor

%% Pause
if cmd_opts.parallel
  pause();
endif
