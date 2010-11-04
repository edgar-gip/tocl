%% -*- mode: octave; -*-

%% Dirichlet distribution clustering
%% Main procedure

%% Author: Edgar Gonzalez

function [ expec, model, info ] = cluster(this, data, k, blocks, expec_0)

  %% Check arguments
  if ~any(nargin() == [ 3, 4, 5 ])
    usage(cstrcat("[ expec, model, info ] = ", ...
		  "@Dirichlet/cluster(data, k [, blocks [, expec_0 ]])"));
  endif

  %% Size
  [ n_dims, n_data ] = size(data);

  %% Are the blocks given?
  if nargin() < 3 || isempty(blocks)
    %% A single block
    blocks = [ n_dims ];
  endif

  %% Starting expectation
  if nargin() < 4
    %% Take it at random
    expec_0   = rand(k, n_data);
    expec_0 ./= ones(k, 1) * sum(expec_0);
    expec_0   = expec_0;

  else
    %% Check the size
    [ expec_0_r, expec_0_c ] = size(expec_0);
    if expec_0_r ~= k || expec_0_c ~= n_data
      usage("expec_0 must be of size k x n_data if present");
    endif
  endif

  %% Find the logarithm of data
  log_data = log(data);

  %% First maximization
  model = maximization(this, log_data, blocks, expec_0);

  %% First expectation
  prev_log_like       = -Inf;
  [ expec, log_like ] = expectation(model, log_data);
  change              = Inf;

  %% Info
  if this.verbose
    fprintf(2, "+");
  endif

  %% Loop
  i = 2;
  while i <= this.em_iterations && log_like < 0 && change >= this.em_threshold
    %% Maximization
    model = maximization(this, log_data, blocks, expec);

    %% Expectation
    prev_log_like       = log_like;
    [ expec, log_like ] = expectation(model, log_data);

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
