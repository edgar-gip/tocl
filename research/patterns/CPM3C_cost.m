%% Cutting Plane Multiclass Maximum Margin Clustering Algorithm (CPM3C)
%% Cost function

%% Author: Edgar Gonzalez

function cost = CPM3C_cost(omega, xi, C)
  %% Find the cost
  cost = 0.5 * sum(sum(omega .^ 2)) + C * xi;

%% Local Variables:
%% mode:octave
%% End:
