%% -*- mode: octave; -*-

%% Support Vector Machines (Revisited)
%% Multiclass kernel SVM with slack variables
%% Distance to hyperplane

%% Author: Edgar Gonzalez

function [ distances ] = multiclass_kernel_svm_distances(data, model)
  %% Kernel matrix
  if model.radial
    %% Radial kernel
    %% | x - y |^2 = x \cdot x + y \cdot y - 2 \cdot x \cdot y
    n_data    = size(data, 2);
    product   = full(model.SV * data);
    self_data = full(sum(data .^ 2, 1)); % 1 * n_data
    K         = model.kernel(model.SV_self * ones(1, n_data) +
                             ones(model.n_SV, 1) * self_data - 2 * product);
  else
    %% Non-radial kernel
    K = model.kernel(full(model.SV * data));
  endif

  %% Multiply and add offset
  distances = full(model.tau * K);
endfunction
