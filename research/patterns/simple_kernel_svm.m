% Support Vector Machines (Revisited)
% Simple version -> Only separable data allowed, but with kernels
% Main procedure

% Author: Edgar Gonzalez

function [ model, info ] = simple_kernel_svm(data, classes, opts)

  % Data and classes should be given
  if nargin() < 2 || nargin() > 3
    usage("[ model, info ] = simple_kernel_svm(data, classes [, opts ] ])");
  end

  % Size
  [ n_dims, n_data ] = size(data);

  % Check classes
  [ classes_r, classes_c ] = size(classes);
  if classes_r ~= 1 || classes_c ~= n_data
    usage("classes must be of size 1 * n_data");
  end

  % Defaults
  if nargin() < 3
    opts = struct();
  elseif ~isstruct(opts)
    usage("opts must be a structure if present");
  end

  % kernel: kernel function
  if ~isfield(opts, "kernel")
    opts.kernel = @(x) (x .+ 1) .^ 2;
  end

  % Create the quadratic programming dual problem
  
  % http://en.wikipedia.org/wiki/Support_vector_machine

  % Objective function: Maximize
  % \frac{1}{2} \cdot -\sum_{i=1}^{n_data} \sum_{j=1}^{n_data}
  %   \alpha_i \alpha_j c_i c_j K(x_i, x_j)
  % + \sum_{i=1}^{n_data} \alpha_i
  % Or minimize the negated...
  H =  (classes' * classes) .* opts.kernel(full(data' * data));
  f = -ones(n_data, 1);

  % Subject to
  % \forall i \; \alpha_i \geq 0
  lb = zeros(n_data, 1);

  % \sum_{i=1}^{n_data} \alpha_i c_i = 0
  Aeq = classes;
  beq = 0;

  % No inequalities
  Ain = zeros(0, n_data);

  % Optimize
  [ alpha, fval, in_info ] = ...
      qp([], H, f, Aeq, beq, lb, [], [], Ain, []);

  % Which are the support vectors?
  SVs    = alpha > 0;
  posSVs = find(SVs & classes' == +1);
  negSVs = find(SVs & classes' == -1);
  if isempty(posSVs) || isempty(negSVs)
    error("Found empty SV set for one (or both) of the classes");
  end

  % Store them in the model
  model        = struct();
  model.kernel = opts.kernel;
  model.alpha  = diag((alpha .* classes')(SVs));
  model.SV     = data(:, SVs)';

  % Find the offset following [Vapnik, 1992]
  % b = -\frac{1}{2} \sum_{x_k \in SV} c_k \cdot \alpha_k \cdot
  %     (K(x_{-1}, x_k) + K(x_{+1}, x_k))
  % for x_{-1} and x_{+1} two arbitrary SVs of each class
  pos_idx = posSVs(1 + floor(size(posSVs, 1) * rand()));
  neg_idx = negSVs(1 + floor(size(negSVs, 1) * rand()));

  % Find it
  model.b = -.5 * sum(model.alpha * ...
		      (model.kernel(model.SV * data(:, pos_idx)) + ...
		       model.kernel(model.SV * data(:, neg_idx))), 1);

  % The function is negated
  fval = -fval;

  % Information
  info            = struct();
  info.iterations = in_info.solveiter;
  info.kernel     = opts.kernel;
  info.obj        = fval;

% Local Variables:
% mode:octave
% End:
