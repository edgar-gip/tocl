%% -*- mode: octave; -*-

%% Support Vector Machines (Revisited)
%% Simple version -> Only separable data allowed
%% Main procedure

%% Author: Edgar Gonzalez

function [ model, info ] = simple_svm(data, classes, opts)

  %% Data and classes should be given
  if nargin() < 2 || nargin() > 3
    usage("[ model, info ] = simple_svm(data, classes [, opts ] ])");
  endif

  %% Size
  [ n_dims, n_data ] = size(data);

  %% Check classes
  [ classes_r, classes_c ] = size(classes);
  if classes_r ~= 1 || classes_c ~= n_data
    usage("classes must be of size 1 * n_data");
  endif

  %% Defaults
  if nargin() < 3
    opts = struct();
  elseif ~isstruct(opts)
    usage("opts must be a structure if present");
  endif

  %% use_dual: use or not dual
  if ~isfield(opts, "use_dual")
    opts.use_dual = true();
  endif

  %% Dual or primal?
  if opts.use_dual
    %% Create the quadratic programming dual problem
  
    %% http://en.wikipedia.org/wiki/Support_vector_machine

    %% Objective function: Maximize
    %% \frac{1}{2} \cdot -\sum_{i=1}^{n_data} \sum_{j=1}^{n_data}
    %%   \alpha_i \alpha_j c_i c_j x_i^T x_j
    %% + \sum_{i=1}^{n_data} \alpha_i
    %% Or minimize the negated...
    H =  (classes' * classes) .* full(data' * data);
    f = -ones(n_data, 1);

    %% Subject to
    %% \forall i \; \alpha_i \geq 0
    lb = zeros(n_data, 1);

    %% \sum_{i=1}^{n_data} \alpha_i c_i = 0
    Aeq = classes;
    beq = 0;

    %% No inequalities
    Ain = zeros(0, n_data);

    %% Optimize
    [ alpha, fval, in_info ] = ...
	qp([], H, f, Aeq, beq, lb, [], [], Ain, []);

    %% Find the weights
    omega = full(data * (alpha .* classes')); % n_dims * 1

    %% Find the offset
    %% (Averaged through all SVs)
    b = mean((classes - full(omega' * data))(alpha > 0));

    %% The function is negated
    fval = -fval;

  else
    %% Create the quadratic programming primal problem

    %% Objective function: Minimize
    %% \frac{1}{2} \sum_{j=1}^{n_dims} \omega_j^2
    H = [ diag(ones(n_dims, 1)), zeros(n_dims, 1) ; zeros(1, n_dims + 1) ];
    f = zeros(n_dims + 1, 1);

    %% Subject to
    %% \forall i
    %%   c_i \cdot (\sum_{j=1}^{n_dims} \omega_j \cdot x_ij + b) \geq 1
    Ain = diag(classes) * ([ full(data)', ones(n_data, 1) ]);
    Alb = ones(n_data, 1);

    %% Optimize
    [ x, fval, in_info ] = ...
	qp([], H, f, [], [], [], [], Alb, Ain, []);

    %% Find the weights
    omega = x(1:n_dims);

    %% Find the offset
    b = x(n_dims + 1);
  endif

  %% Create the model
  model       = struct();
  model.omega = omega;
  model.b     = b;

  %% Information
  info            = struct();
  info.iterations = in_info.solveiter;
  info.use_dual   = opts.use_dual;
  info.obj        = fval;
endfunction
