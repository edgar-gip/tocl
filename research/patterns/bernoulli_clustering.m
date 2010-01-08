% Bernoulli distribution clustering
% Main procedure

% Author: Edgar Gonzalez

function [ expec, model, info ] = bernoulli_clustering(data, k, opts)

  % Data and k must be given
  if nargin() < 2 || nargin() > 3
    usage('[ expec, model, info ] = bernoulli_clustering(data, k [, opts ])');
  end;

  % Size
  [ n_dims, n_data ] = size(data);

  % Are the options given?
  if nargin() < 3
    opts = struct();
  elseif ~isstruct(opts)
    usage('opts must be a structure if present');
  end;

  % Starting expectation
  if ~isfield(opts, 'expec_0')
    % Take it at random
    expec_0   = rand(k, n_data);
    expec_0 ./= ones(k, 1) * sum(expec_0);
    opts.expec_0 = expec_0;
  else
    % Check the size
    [ expec_0_r, expec_0_c ] = size(opts.expec_0);
    if expec_0_r ~= k || expec_0_c ~= n_data
      usage('opts.expec_0 must be of size k x n_data if present');
    end;
  end;

  % Maximum number of iterations
  if ~isfield(opts, 'em_iterations')
    % Default -> 100
    opts.em_iterations = 100;
  end;

  % Variance threshold
  if ~isfield(opts, 'em_threshold')
    % Default -> 1e-6
    opts.em_threshold = 1e-6;
  end;

  % First maximization
  model = bernoulli_maximization(data, opts.expec_0);

  % First expectation
  prev_log_like       = -Inf;
  [ expec, log_like ] = bernoulli_expectation(data, model);
  change              = Inf;

  % Info
  fprintf(2, '+');

  % Loop
  i = 2;
  while i <= opts.em_iterations && change >= opts.em_threshold
    % Maximization
    model = bernoulli_maximization(data, expec);

    % Expectation
    prev_log_like       = log_like;
    [ expec, log_like ] = bernoulli_expectation(data, model);

    % Change
    change = (log_like - prev_log_like) / abs(prev_log_like);

    % Display
    if rem(i, 10) == 0
      fprintf(2, '. %6d %8g %8g\n', i, log_like, change);
    else
      fprintf(2, '.');
    end;

    % Next iteration
    ++i;
  end;

  % Display final output
  fprintf(2, ' %6d %8g %8g %8g\n', i, log_like, change);

  % Return the information
  info               = struct();
  info.expec_0       = opts.expec_0;
  info.em_iterations = opts.em_iterations;
  info.em_threshold  = opts.em_threshold;
  info.iterations    = i;
  info.log_like      = log_like;
  info.prev_log_like = prev_log_like;
  info.change        = change;

% Local Variables:
% mode:octave
% End:
