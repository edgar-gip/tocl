%% -*- mode: octave; -*-

%% Support Vector Machines (Revisited)
%% Simple version -> Two points only, but with kernels
%% Main procedure

%% Author: Edgar Gonzalez

function [ model, info ] = twopoint_kernel_svm(data, opts)

  %% Data should be given
  if nargin() < 1 || nargin() > 2
    usage("[ model, info ] = twopoint_kernel_svm(data, [, opts ] ])");
  endif

  %% Size
  [ n_dims, n_data ] = size(data);
  if n_data ~= 2
    usage("Two data points must be given");
  endif

  %% Defaults
  if nargin() < 2
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

  %% Adapt the quadratic programming dual problem

  %% http://en.wikipedia.org/wiki/Support_vector_machine

  %% Kernel matrix
  [ K, self_data ] = kernel_matrix(data, opts.radial, opts.kernel);

  %% Given there is only two datapoints, and that c_1 = -c_2:
  %%   \alpha_1 = \alpha_2 = \alpha
  %%   F = 2 * \alpha
  %%     - \frac{1}{2} \alpha^2 \cdot ( K(x_1, x_1) + K(x_2, x_2)
  %%                                  - 2 \cdot K(x_1, x_2) )
  %% From where, at the maximum:
  %%   \alpha = \frac{2}{K(x_1, x_1) + K(x_2, x_2) - 2 \cdot K(x_1, x_2)}
  %% And
  %%   F = \alpha

  dist  = K(1,1) + K(2,2) - 2 * K(1,2);
  alpha = 2 / dist;
  %% fval  = alpha;

  %% Find the offset following [Vapnik, 1982], [Boser et al, 1992]
  %% Which becomes
  %%   b = -\frac{1}{2} \cdot \alpha \cdot (K(x_1, x_1) - K(x_2, x_2))
  b = -.5 * alpha * (K(1, 1) - K(2, 2));

  %% Store them in the model
  model        = struct();
  model.radial = opts.radial;
  model.kernel = opts.kernel;
  model.alpha  = diag([ alpha, -alpha ]);
  model.SV     = data';
  model.b      = b;

  %% A radial kernel?
  if model.radial
    %% Add self product and number of SVs
    model.SV_self = self_data;
    model.n_SV    = 2;
  endif

  %% Information
  info            = struct();
  info.iterations = 0;
  info.obj        = alpha; % fval
endfunction
