% Support Vector Machines (Revisited)
% Simple version -> Only separable data allowed, but with kernels
% Distance to hyperplane

% Author: Edgar Gonzalez

function [ distances ] = simple_kernel_svm_distances(data, model)

  % Multiply and add offset
  distances = sum(model.alpha * model.kernel(model.SV * data), 1) + model.b;

% Local Variables:
% mode:octave
% End:
							 
