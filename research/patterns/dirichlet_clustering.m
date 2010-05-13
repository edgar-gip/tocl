%% -*- mode: octave; -*-

%% Dirichlet distribution clustering
%% Main procedure

%% Author: Edgar Gonzalez

function [ expec, model, info ] = dirichlet_clustering(data, k, blocks, opts)

  %% Data, blocks and k must be given
  if nargin() < 2 || nargin() > 4
    usage(cstrcat("[ expec, model, info ] = ", ...
		  "dirichlet_clustering(data, k [, blocks [, opts ]])"));
  endif

  %% Size
  [ n_dims, n_data ] = size(data);

  %% Are the blocks given?
  if nargin() < 3 || isempty(blocks)
    %% A single block
    blocks = [ n_dims ];
  endif

  %% Are the options given?
  if nargin() < 4
    opts = struct();
  elseif ~isstruct(opts)
    usage("opts must be a structure if present");
  endif

  %% Starting expectation
  if ~isfield(opts, "expec_0")
    %% Take it at random
    expec_0   = rand(k, n_data);
    expec_0 ./= ones(k, 1) * sum(expec_0);
    opts.expec_0 = expec_0;
  else
    %% Check the size
    [ expec_0_r, expec_0_c ] = size(opts.expec_0);
    if expec_0_r ~= k || expec_0_c ~= n_data
      usage("opts.expec_0 must be of size k x n_data if present");
    endif
  endif

  %% Maximum number of iterations
  if ~isfield(opts, "em_iterations")
    %% Default -> 100
    opts.em_iterations = 100;
  endif

  %% Variance threshold
  if ~isfield(opts, "em_threshold")
    %% Default -> 1e-6
    opts.em_threshold = 1e-6;
  endif

  %% Verbose
  if ~isfield(opts, "verbose")
    %% Default -> false
    opts.verbose = false();
  endif

  %% Find the logarithm of data
  log_data = log(data);

  %% First maximization
  model = dirichlet_maximization(log_data, blocks, opts.expec_0);

  %% First expectation
  prev_log_like       = -Inf;
  [ expec, log_like ] = dirichlet_expectation(log_data, model);
  change              = Inf;

  %% Info
  if opts.verbose
    fprintf(2, "+");
  endif

  %% Loop
  i = 2;
  while i <= opts.em_iterations && log_like < 0 && change >= opts.em_threshold
    %% Maximization
    model = dirichlet_maximization(log_data, blocks, expec);

    %% Expectation
    prev_log_like       = log_like;
    [ expec, log_like ] = dirichlet_expectation(log_data, model);

    %% Change
    change = (log_like - prev_log_like) / abs(prev_log_like);

    %% Display
    if opts.verbose
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
  if opts.verbose
    fprintf(2, " %6d %8g %8g %8g\n", i, log_like, change);
  endif

  %% Return the information
  info               = struct();
  info.expec_0       = opts.expec_0;
  info.em_iterations = opts.em_iterations;
  info.em_threshold  = opts.em_threshold;
  info.iterations    = i;
  info.log_like      = log_like;
  info.prev_log_like = prev_log_like;
  info.change        = change;
endfunction
