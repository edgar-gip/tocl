%% Support Vector Machines (Revisited)
%% Simple version -> Only separable data allowed, but with kernels
%% Distance to hyperplane

%% Author: Edgar Gonzalez

function [ distances ] = simple_kernel_svm_distances(data, model)

  %% Kernel matrix
  if model.radial
    %% Radial kernel
    %% | x - y |^2 = x \cdot x + y \cdot y - 2 \cdot x \cdot y
    product   = full(model.SV * data);
    self_data = full(sum(data .^ 2, 1)); % 1 * n_data
    K         = model.kernel(model.SV_self * ones(1, n_data) + 
			     ones(model.n_SV, 1) * self_data - 2 * product);
  else
    %% Non-radial kernel
    K  = model.kernel(full(model.SV * data));
  end

  %% Multiply and add offset
  distances = sum(model.alpha * K, 1) + model.b;

%% Local Variables:
%% mode:octave
%% End:
