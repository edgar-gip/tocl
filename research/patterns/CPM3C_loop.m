%% -*- mode: octave; -*-

%% Cutting Plane Multiclass Maximum Margin Clustering Algorithm (CPM3C)
%% Main loop

%% Author: Edgar Gonzalez

%% Based in CPMMC.m
%% Author: Bin Zhao

function [ expec, model, info ] = CPM3C_loop(data, k, opts)

  %%%%%%%%%%%%%%%%%%%%%
  %% Data statistics %%
  %%%%%%%%%%%%%%%%%%%%%

  %% Sizes
  [ n_dims, n_data ] = size(data);

  %% Sum of the data
  sum_data = full(sum(data, 2));


  %%%%%%%%%%%%%%%%%%%%
  %% Initial values %%
  %%%%%%%%%%%%%%%%%%%%

  %% omega
  omega = opts.omega_0;

  %% xi
  xi = opts.xi_0;

  %% Constraint set
  W   = {};
  n_W = 0;


  %%%%%%%%%%%
  %% Solve %%
  %%%%%%%%%%%

  %% Find the most violated constraint in the original problem
  [ constraint, violation, z ] = CPM3C_mvc(data, omega);

  %% Add first constraint
  n_W = n_W + 1;
  W{1,n_W} = constraint;
  active   = full(sum(constraint));
  W{2,n_W} = sparse(1:n_data, 1:n_data, active, n_data, n_data);
  W{3,n_W} = sum(active) / n_data;

  %% Loop
  iterations = 0;
  finish     = 0;
  while ~finish
    %% Solve the non-convex optimization problem via CCCP
    [ omega, xi, obj, its ] = ...
        CPM3C_CCCP(data, omega, xi, W, opts.C, opts.l, opts.per_quit,
                   sum_data, z, iterations, violation, opts.verbose);

    %% Add the iterations
    iterations = iterations + its;

    %% Find the most violated constraint in the original problem
    [ constraint, violation, z ] = CPM3C_mvc(data, omega);

    %% Finish?
    if violation <= xi * (1 + opts.epsilon)
      finish = 1;
    else
      n_W      = n_W + 1;
      W{1,n_W} = constraint;
      active   = full(sum(constraint));
      W{2,n_W} = sparse(1:n_data, 1:n_data, active, n_data, n_data);
      W{3,n_W} = sum(active) / n_data;
    endif
  endwhile

  %% Display final output
  if opts.verbose
    fprintf(2, " %6d %4d %8g %8g %8g\n", iterations, size(W, 2), ...
            obj, xi, violation);
  endif

  %% Classify
  clusters = CPM3C_cluster(data, omega);
  expec    = sparse(1 + clusters, 1:n_data, ones(1, n_data));

  %% Model
  model       = struct();
  model.omega = omega;

  %% Information
  info             = opts;
  info.xi          = xi;
  info.W           = W;
  info.obj         = obj;
  info.iterations  = iterations;
  info.constraints = size(W, 2);
  info.violation   = violation;
endfunction
