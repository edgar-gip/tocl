% Cutting Plane Multiclass Maximum Margin Clustering Algorithm (CPM3C)
% Cost function

% Author: Edgar Gonzalez
% Created on: 14 December, 2009

function cost = CPM3C_cost(omega, xi, C)
  % Find the cost
  cost = 0.5 * sum(sum(omega .^ 2)) + C * xi;

% Local Variables:
% mode:octave
% End:
