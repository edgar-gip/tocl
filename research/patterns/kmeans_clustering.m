% k-Means clustering
% Main procedure

% Author: Edgar Gonzalez

function [ expec, model, info ] = kmeans_clustering(data, k, opts)

  % Data and k must be given
  if nargin() < 2 || nargin() > 3
    usage("[ expec, model, info ] = kmeans_clustering(data, k [, opts ])");
  end

  % Size
  [ n_dims, n_data ] = size(data);

  % Are the options given?
  if nargin() < 3
    opts = struct();
  elseif ~isstruct(opts)
    usage("opts must be a structure if present");
  end

  % Starting expectation
  if ~isfield(opts, "expec_0")
    % Take it at random
    expec_0   = rand(k, n_data);
    expec_0 ./= ones(k, 1) * sum(expec_0);
    opts.expec_0 = expec_0;
  else
    % Check the size
    [ expec_0_r, expec_0_c ] = size(opts.expec_0);
    if expec_0_r ~= k || expec_0_c ~= n_data
      usage("opts.expec_0 must be of size k x n_data if present");
    end
  end

  % Maximum number of iterations
  if ~isfield(opts, "em_iterations")
    % Default -> 100
    opts.em_iterations = 100;
  end

  % Variance threshold
  if ~isfield(opts, "em_threshold")
    % Default -> 1e-6
    opts.em_threshold = 1e-6;
  end

  % Verbose
  if ~isfield(opts, "verbose")
    % Default -> false
    opts.verbose = false();
  end

  % Auto-dot-product matrix
  auto_data = sum(data .* data); % 1 * n_data

  % First maximization
  model           = struct();
  model.centroids = data * opts.expec_0' / n_data; % n_dims * k

  % First expectation
  prev_sum_sq       = Inf;
  [ expec, sum_sq ] = kmeans_expectation(data, model, auto_data);
  change            = Inf;

  % Info
  if opts.verbose
    fprintf(2, "+");
  end

  % Loop
  i = 2;
  while i <= opts.em_iterations && change >= opts.em_threshold
    % Maximization
    model.centroids = data * expec' / n_data; % n_dims * k

    % Expectation
    prev_sum_sq         = sum_sq;
    [ expec, sum_sq ] = kmeans_expectation(data, model, auto_data);

    % Change
    change = (prev_sum_sq - sum_sq) / sum_sq;

    % Display
    if opts.verbose
      if rem(i, 10) == 0
	fprintf(2, ". %6d %8g %8g\n", i, sum_sq, change);
      else
	fprintf(2, ".");
      end
    end

    % Next iteration
    ++i;
  end

  % Display final output
  if opts.verbose
    fprintf(2, " %6d %8g %8g %8g\n", i, sum_sq, change);
  end

  % Return the information
  info               = struct();
  info.expec_0       = opts.expec_0;
  info.em_iterations = opts.em_iterations;
  info.em_threshold  = opts.em_threshold;
  info.iterations    = i;
  info.sum_sq        = sum_sq;
  info.prev_sum_sq   = prev_sum_sq;
  info.change        = change;

% Local Variables:
% mode:octave
% End:
