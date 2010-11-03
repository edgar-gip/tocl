%% -*- mode: octave; -*-

%% Bernoulli distribution clustering
%% Main procedure

%% Author: Edgar Gonzalez

function [ expec, model, info ] = cluster(this, data, k, expec_0)

  %% Data and k must be given
  if nargin() < 3 || nargin() > 4
    usage(cstrcat("[ expec, model, info ] = ", ...
		  "@Bernoulli/cluster(this, data, k [, expec_0 ])"));
  endif

  %% Size
  [ n_dims, n_data ] = size(data);

  %% Is the starting expectation given?
  if nargin() < 4
    %% Take it at random
    expec_0   = rand(k, n_data);
    expec_0 ./= ones(k, 1) * sum(expec_0);
  else
    %% Check the size
    [ expec_0_r, expec_0_c ] = size(expec_0);
    if expec_0_r ~= k || expec_0_c ~= n_data
      usage("expec_0 must be of size k x n_data if present");
    endif
  endif

  %% First maximization
  model = maximization(this, data, expec_0);

  %% First expectation
  prev_log_like       = -Inf;
  [ expec, log_like ] = expectation(model, data);
  change              = Inf;

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

    %% Next iteration
    ++i;
  endwhile

  %% Display final output
  if this.verbose
    fprintf(2, " %6d %8g %8g %8g\n", i, log_like, change);
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
endfunction
