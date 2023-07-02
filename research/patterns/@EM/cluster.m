%% -*- mode: octave; -*-

%% Expectation-Maximization clustering
%% Main procedure

%% Author: Edgar Gonzalez

function [ expec, model, info ] = cluster(this, data, k, expec_0)

  %% Check arguments
  if ~any(nargin() == [ 3, 4 ])
    usage(cstrcat("[ expec, model, info ] = ", ...
                  "@EM/cluster(this, data, k [, expec_0 ])"));
  endif

  %% Size
  [ n_dims, n_data ] = size(data);

  %% Is the starting expectation given?
  if nargin() < 4
    %% Take it at random
    expec_0 = random_expec(this, data, k);

  else
    %% Check the size
    [ expec_0_r, expec_0_c ] = size(expec_0);
    if expec_0_r ~= k || expec_0_c ~= n_data
      usage("expec_0 must be of size k x n_data if present");
    endif
  endif

  %% Plot?
  if this.plot
    fig = figure();
  else
    fig = [];
  endif

  %% First maximization
  model = maximization(this, data, expec_0);

  %% First expectation
  prev_log_like       = -Inf;
  [ expec, log_like ] = expectation(model, data);
  change              = Inf;

  %% Plot
  if this.plot
    figure(fig, "name", sprintf("EM: Iteration 1"));
    expectation_plot(data, model, expec, true, fig);
    if isempty(this.plot_delay)
      replot();
    else
      pause(this.plot_delay);
    endif
  endif

  %% Info
  if this.verbose
    fprintf(2, "+");
  endif

  %% Loop
  i = 2;
  while i <= this.em_iterations && change >= this.em_threshold
    %% Maximization
    model = maximization(this, data, expec);

    %% Expectation
    prev_log_like       = log_like;
    [ expec, log_like ] = expectation(model, data);

    %% Change
    change = (log_like - prev_log_like) / abs(prev_log_like);

    %% Display
    if this.verbose
      if rem(i, 10) == 0
        fprintf(2, ". %6d %8g %8g\n", i, log_like, change);
      else
        fprintf(2, ".");
      endif
    endif

    %% Plot
    if this.plot
      figure(fig, "name", sprintf("EM: Iteration %d", i));
      expectation_plot(data, model, expec, true, fig);
      if isempty(this.plot_delay)
        replot();
      else
        pause(this.plot_delay);
      endif
    endif

    %% Next iteration
    ++i;
  endwhile

  %% Display final output
  if this.verbose
    fprintf(2, " %6d %8g %8g\n", i, log_like, change);
  endif

  %% Plot
  if this.plot
    figure(fig, "name", "EM");
  endif

  %% Return the information
  info               = struct();
  info.expec_0       = expec_0;
  info.em_iterations = this.em_iterations;
  info.em_threshold  = this.em_threshold;
  info.iterations    = i;
  info.log_like      = log_like;
  info.prev_log_like = prev_log_like;
  info.change        = change;
  info.fig           = fig;
endfunction
