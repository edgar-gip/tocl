%% -*- mode: octave; -*-

%% Support Vector Machines (Revisited)
%% Kernel Matrix

%% Author: Edgar Gonzalez

function [ K, self_data ] = kernel_matrix(data, radial, kernel)
  %% Is it radial?
  if radial
    %% Radial kernel
    %% | x - y |^2 = x \cdot x + y \cdot y - 2 \cdot x \cdot y
    K         = full(data' * data);
    self_data = diag(K, 0);
    n_data    = size(data, 2);
    K         = kernel(self_data * ones(1, n_data) + ...
		       ones(n_data, 1) * self_data' - 2 * K);
  else
    %% Non-radial kernel
    K         = kernel(full(data' * data));
    self_data = [];
  endif
endfunction
