%% Support Vector Machines (Revisited)
%% Simple version -> Two points only
%% Main procedure

%% Author: Edgar Gonzalez

function [ model, info ] = twopoint_svm(data, opts)

  %% Data should be given
  if nargin() < 1 || nargin() > 2
    usage("[ model, info ] = twopoint_kernel_svm(data, [, opts ] ])");
  endif

  %% Size
  [ n_dims, n_data ] = size(data);
  if n_data != 2
    usage("Two data points must be given");
  endif

  %% Defaults
  if nargin() < 2
    opts = struct();
  elseif ~isstruct(opts)
    usage("opts must be a structure if present");
  end

  %% Adapt the quadratic programming dual problem
  %% see twopoint_kernel_svm.m

  %% Just find the distances
  diff  = data(:,1) - data(:,2);
  alpha = 2 / sum(diff .* diff);
  %% fval  = alpha;

  %% Explicitly construct the weights as
  %%   \omega = \alpha * (x_1 - x_2)
  omega = alpha * diff;

  %% Find the offset
  b = .5 * sum(omega' * sum(data, 2));

  %% Store them in the model
  model        = struct();
  model.omega  = omega;
  model.b      = b;

  %% Information
  info            = struct();
  info.iterations = 0;
  info.obj        = alpha; % fval

%% Local Variables:
%% mode:octave
%% End:
