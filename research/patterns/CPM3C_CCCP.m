% Cutting Plane Multiclass Maximum Margin Clustering Algorithm (CPM3C)
% Inner CCCP procedure

% Author: Edgar Gonzalez

% Based in CCCP_MMC_dual.m
% Author: Bin Zhao

function [ omega, xi, obj, its ] = ...
      CPM3C_CCCP(data, omega, xi, W, C, l, per_quit, sum_data, z, ...
		 iterations, violation, verbose)

  % Sizes
  [ n_dims, n_data ] = size(data);
  [ n_dims, k      ] = size(omega);
  n_weights          = n_dims * k;
  n_constraints      = size(W, 2);

  % X arrangement
  % [ \omega_{11} ... \omega_{1m}, \omega_{21} ... \omega_{km}, \xi ]

  % Objective function:
  % \sum_{p=1}^k \sum_{j=1}^m \omega_{pj}^2 + C \cdot \xi
  H = [ eye(n_weights), zeros(n_weights, 1) ; zeros(1, n_weights + 1) ];
  f = [ zeros(n_weights, 1) ; C ];

  % Inequalities:
  Ain = zeros(k * (k - 1) / 2 + n_constraints, n_weights + 1);
  blb = [ -l * ones(k * (k - 1) / 2, 1) ; -inf * ones(n_constraints, 1) ];
  bub = [ +l * ones(k * (k - 1) / 2, 1) ;       zeros(n_constraints, 1) ];

  % -> Size inequalities
  %    Do not change across iterations
  cidx = 0;
  for p = 1:k
    pw = (p - 1) * n_dims;
    for q = 1:p-1
      qw = (q - 1) * n_dims;

      % -l <=  \sum_{i=1}^n \sum_{j=1}^m \omega_{pj} \cdot x_{ij} -
      %      - \sum_{i=1}^n \sum_{j=1}^m \omega_{qj} \cdot x_{ij} <= l
      cidx = cidx + 1;
      % blb(cidx)                     = -l;
      Ain(cidx, (pw+1):(pw+n_dims)) =  sum_data;
      Ain(cidx, (qw+1):(qw+n_dims)) = -sum_data;
      % bub(cidx)                     = +l;
    end
  end

  % Equalities:
  Aeq = [];
  beq = [];

  % Ranges:
  % xi >= 0
  lb = [ -inf * ones(n_weights, 1) ; 0 ];
  ub =    inf * ones(n_weights + 1, 1);

  % Starting value:
  startx = [ reshape(omega, n_weights, 1) ; xi ];

  % Starting objective function value
  obj = CPM3C_cost(omega, xi, C);
  
  % Display
  if verbose
    if rem(iterations + 1, 10) == 0
      fprintf(2, "+ %6d %4d %8g %8g %8g\n", iterations + 1, nConstraints, ...
	      obj, xi, violation);
    else
      fprintf(2, "+");
    end
  end

  % Loop
  its    = 1;
  finish = 0;
  while ~finish
    % Remember old objective function value
    old_obj = obj;

    % Generate the extra inequalities
    % -> Constraints
    xcidx = cidx;
    for w = 1:n_constraints
      % Get it
      constraint  = W{1,w};
      active      = W{2,w};
      mean_active = W{3,w};

      % Coefficient matrix
      coeffs      = full(data * (constraint - z * active)' / n_data);

      % Create the inequality
      xcidx = xcidx + 1;
      Ain(xcidx, :) = [ reshape(coeffs, 1, n_weights), -1 ];
      bub(xcidx)    = sum(sum(constraint .* z)) / n_data - mean_active;
    end

    % Solve
    [ x, obj ] = qp(startx, H, f, Aeq, beq, lb, ub, blb, Ain, bub);

    % Unpack
    omega = reshape(x(1:n_weights), n_dims, k);
    xi    = x(n_weights + 1);

    % Display
    if verbose
      if rem(iterations + its + 1, 10) == 0
	fprintf(2, ". %6d %4d %8g %8g %8g\n", iterations + its + 1, ...
		n_constraints, obj, xi, violation);
      else
	fprintf(2, ".");
      end
    end

    % Finish?
    if old_obj - obj >= 0 && old_obj - obj < per_quit * old_obj
      % Finish!
      finish = 1;
    else
      % Update z
      z = CPM3C_z(data, omega);

      % Start from here
      startx = x;
    end

    % One more iteration
    its = its + 1;
  end
  
% Local Variables:
% mode:octave
% End:
