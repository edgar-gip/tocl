%% -*- mode: octave; -*-

%% Support Vector Machines (Revisited)

%% Multiclass kernel SVM with slack variables

%% Following the approach of:
%%  K. Crammer, Y. Singer,
%%  "On the Algorithmic Implementation of Multiclass Kernel-based
%%   Vector Machines",
%% Journal of Machine Learning Research, 2 (2001), 265--292

%% Main procedure

%% Author: Edgar Gonzalez

function [ model, info, problem ] = multiclass_kernel_svm(data, classes, opts)

  %% Data and classes should be given
  if nargin() < 2 || nargin() > 3
    usage("[ model, info ] = simple_kernel_svm(data, classes [, opts ] ])");
  endif

  %% Size
  [ n_dims, n_data ] = size(data);

  %% Check classes
  [ n_classes, classes_c ] = size(classes);
  if classes_c ~= n_data
    usage("classes must be of size 1 * n_data or k * n_data");
  endif

  %% Convert to sparse matrix if needed
  if n_classes == 1
    classes   = sparse(classes, 1 : n_data, ones(1, n_data));
    n_classes = size(classes, 1);
  endif

  %% Defaults
  if nargin() < 3
    opts = struct();
  elseif ~isstruct(opts)
    usage("opts must be a structure if present");
  endif

  %% radial: is the kernel radial?
  if ~isfield(opts, "radial")
    opts.radial = false();
  endif

  %% kernel: kernel function
  if ~isfield(opts, "kernel")
    if opts.radial
      opts.kernel = @(x) exp(-x);
    else
      opts.kernel = @(x) (x .+ 1) .^ 2;
    endif
  endif

  %% C: weights/error tradeoff
  if ~isfield(opts, "C")
    opts.C = 1;
  endif

  %% beta is the inverse of C
  beta = 1 / opts.C;

  %% Create the quadratic programming dual problem
  %% We will have n_classes * n_data variables
  %% [ \tau_{1,1} ... \tau_{1,n_classes} ...
  %%   \tau_{n_data,1} ... \tau_{n_data,n_classes}
  n_vars = n_classes * n_data;

  %% Flatten the classes
  flat_classes = reshape(classes, n_vars, 1);

  %% Kernel matrix
  [ K, self_data ] = kernel_matrix(data, opts.radial, opts.kernel);

  %% Objective function: Maximize
  %% \frac{1}{2} \cdot -\sum_{i=1}^{n_data} \sum_{j=1}^{n_data}
  %%   (\sum_{m=1}^{k} \tau_{im} \cdot \tau_{jm}) \cdot \K(x_i, x_j)
  %% + \beta \cdot \sum_{i=1}^{n_data} \tau_{iy_i}
  %% Or minimize the negated...
  H = matrix_eyeblockize(K, n_classes);
  f = -beta * full(flat_classes);

  %% <- There used to be a bug here
  %% H = matrix_blockize(K, n_classes, n_classes);

  %% Subject to
  %% \forall i, r \tau_{ir} \leq \delta(y_i, r)
  lb = -inf * ones(n_vars, 1);
  ub = full(flat_classes);

  %% \forall i \sum_{r=1}^{n_classes} \tau_{ir} = 0
  Aeq = matrix_blockize(diag(ones(1, n_data)), 1, n_classes);
  beq = zeros(n_data, 1);

  %% No inequalities
  Ain = zeros(0, n_classes * n_data);

  %% Optimize
  %% Should be: qp([], H, f, Aeq, beq, lb, ub, [], Ain, [])
  %% but it just doesn't work... Buggy octave...
  [ raw_tau, fval, in_info ] = ...
      quadprog_cgal(H, f, Aeq, beq, [], [], lb, ub);

  %% Restructure tau
  tau = reshape(raw_tau, n_classes, n_data);

  %% Keep those samples that have some tau different from zero
  SVs = find(any(tau));
  if isempty(SVs)
    error("Found empty SV set");
  endif

  %% Store them in the model
  model        = struct();
  model.radial = opts.radial;
  model.kernel = opts.kernel;
  model.tau    = sparse(tau(:, SVs));
  model.SV     = data(:, SVs)';

  %% A radial kernel?
  if model.radial
    %% Add self product and number of SVs
    model.SV_self = self_data(SVs); % n_SV * 1
    model.n_SV    = size(model.SV, 1);
  endif

  %% The function is negated
  fval = -fval;

  %% Information
  info            = struct();
  info.iterations = in_info.iterations;
  info.obj        = fval;
  info.status     = in_info.status();

  %% Problem
  problem      = struct();
  problem.H    = H;
  problem.f    = f;
  problem.lb   = lb;
  problem.ub   = ub;
  problem.Aeq  = Aeq;
  problem.beq  = beq;
  problem.Ain  = Ain;
  problem.bin  = 0;
  problem.x    = raw_tau;
  problem.fval = fval;
  problem.info = in_info;
endfunction
