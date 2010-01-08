% Cutting Plane Maximum Margin Clustering Algorithm (CPMMC)
% Main loop

% Author: Edgar Gonzalez

% Based in CPMMC.m
% Author: Bin Zhao

function [ expec, model, info ] = CPMMC_loop(data, opts)

  %%%%%%%%%%%%%%%%%%%
  % Data statistics %
  %%%%%%%%%%%%%%%%%%%

  % Sizes
  [ n_dims, n_data ] = size(data);

  % Sum of the data
  sum_data = full(sum(data, 2));


  %%%%%%%%%%%%%%%%%%
  % Initial values %
  %%%%%%%%%%%%%%%%%%

  % omega
  omega = opts.omega_0;

  % b
  b = opts.b_0;

  % xi
  xi = opts.xi_0;


  %%%%%%%%%
  % Solve %
  %%%%%%%%%

  % Find the most violated constraint in the original problem
  [ constraint, violation ] = CPMMC_mvc(data, omega, b);

  % Add first constraint
  W   = constraint;
  c_k = mean(constraint, 1);

  % Loop
  iterations = 0;
  finish     = 0;
  while ~finish
    % Solve the non-convex optimization problem via CCCP
    [ omega, b, xi, obj, its ] = ...
	CPMMC_CCCP_dual(data, omega, b, xi, W, opts.C, opts.l, ...
			opts.per_quit, sum_data, c_k, iterations, violation);

    % Find the most violated constraint in the original problem
    [ constraint, violation ] = CPMMC_mvc(data, omega, b);

    % Finish?
    if violation <= xi * (1 + opts.epsilon)
      finish = 1;
    else
      W   = [ W, constraint ];
      c_k = [ c_k, mean(constraint, 1) ];
    end;
  end;

  % Display final output
  fprintf(2, ' %6d %4d %8g %8g %8g\n', iterations, size(W, 2), ...
          obj, xi, violation);

  % Expectation
  clusters = 2 * sign(omega' * data + b) + 1;
  expec    = sparse(clusters, 1:n_data, ones(1, n_data));

  % Model
  model       = struct();
  model.omega = omega;
  model.b     = b;

  % Information
  info             = opts;
  info.xi          = xi;
  info.W           = W;
  info.obj         = obj;
  info.iterations  = iterations;
  info.constraints = size(W, 2);
  info.violation   = violation;

% Local Variables:
% mode:octave
% End:
