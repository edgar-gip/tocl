%% Support Vector Machines (Revisited)
%% Simple version -> Only separable data allowed, but with kernels
%% Main procedure

%% Author: Edgar Gonzalez

function [ model, info ] = simple_kernel_svm(data, classes, opts)

  %% Data and classes should be given
  if nargin() < 2 || nargin() > 3
    usage("[ model, info ] = simple_kernel_svm(data, classes [, opts ] ])");
  end

  %% Size
  [ n_dims, n_data ] = size(data);

  %% Check classes
  [ classes_r, classes_c ] = size(classes);
  if classes_r ~= 1 || classes_c ~= n_data
    usage("classes must be of size 1 * n_data");
  end

  %% Defaults
  if nargin() < 3
    opts = struct();
  elseif ~isstruct(opts)
    usage("opts must be a structure if present");
  end

  %% radial: is the kernel radial?
  if ~isfield(opts, "radial")
    opts.radial = false();
  end

  %% kernel: kernel function
  if ~isfield(opts, "kernel")
    opts.kernel = @(x) (x .+ 1) .^ 2;
  end

  %% Create the quadratic programming dual problem
  
  %% http://en.wikipedia.org/wiki/Support_vector_machine

  %% Kernel matrix
  if opts.radial
    %% Radial kernel
    %% | x - y |^2 = x \cdot x + y \cdot y - 2 \cdot x \cdot y
    K         = full(data' * data);
    self_data = diag(K, 0);
    K         = opts.kernel(self_data * ones(1, n_data) + ...
			    ones(n_data, 1) * self_data' - 2 * K);
  else
    %% Non-radial kernel
    K  = opts.kernel(full(data' * data));
  end

  %% Objective function: Maximize
  %% \frac{1}{2} \cdot -\sum_{i=1}^{n_data} \sum_{j=1}^{n_data}
  %%   \alpha_i \alpha_j c_i c_j K(x_i, x_j)
  %% + \sum_{i=1}^{n_data} \alpha_i
  %% Or minimize the negated...
  H = (classes' * classes) .* K;
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

  %% Which are the support vectors?
  SVs    = alpha > 0;
  posSVs = find(SVs & classes' == +1);
  negSVs = find(SVs & classes' == -1);
  if isempty(posSVs) || isempty(negSVs)
    error("Found empty SV set for one (or both) of the classes");
  end

  %% Store them in the model
  model        = struct();
  model.radial = opts.radial;
  model.kernel = opts.kernel;
  model.alpha  = diag((alpha .* classes')(SVs));
  model.SV     = data(:, SVs)';

  %% Find the offset following [Vapnik, 1982], [Boser et al, 1992]
  %% b = -\frac{1}{2} \sum_{x_k \in SV} c_k \cdot \alpha_k \cdot
  %%     (K(x_{-1}, x_k) + K(x_{+1}, x_k))
  %% for x_{-1} and x_{+1} two arbitrary SVs of each class
  pos_idx = posSVs(1 + floor(size(posSVs, 1) * rand()));
  neg_idx = negSVs(1 + floor(size(negSVs, 1) * rand()));

  %% Find it
  model.b = -.5 * sum(model.alpha * sum(K(SVs, [ pos_idx, neg_idx ]), 2), 1);

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
  info.iterations = in_info.solveiter;
  info.obj        = fval;

%% Local Variables:
%% mode:octave
%% End:
