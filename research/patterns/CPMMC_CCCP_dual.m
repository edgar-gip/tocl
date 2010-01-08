% Cutting Plane Maximum Margin Clustering Algorithm (CPMMC)
% Inner CCCP procedure

% Author: Edgar Gonzalez

% Based in CCCP_MMC_dual.m
% Author: Bin Zhao

function [ omega, b, xi, obj, its ] = ...
      CPMMC_CCCP_dual(data, omega, b, xi, W, C, l, per_quit, x_k, c_k, ...
		      iterations, violation, verbose);

  % Sizes
  [ n_data, n_constraints ] = size(W);
  [ n_dims,          temp ] = size(omega);

  % Starting objective function value
  obj = CPM3C_cost(omega, xi, C);
  
  % Display
  if verbose
    if rem(iterations + 1, 10) == 0
      fprintf(2, "+ %6d %4d %8g %8g %8g\n", iterations + 1, n_constraints, ...
	      obj, xi, violation);
    else
      fprintf(2, "+");
    end
  end

  % Objective function
  % H = <changing>
  f = [ -c_k ; l ; l ];

  % Inequalities
  Ain = [ ones(1, n_constraints), 0, 0 ];
  blb = -inf;
  bub =  C;

  % Equalities
  % Aeq = <changing>
  beq = 0;

  % Ranges
  lb =      zeros(n_constraints + 2, 1);
  ub = inf * ones(n_constraints + 2, 1);

  % Starting value
  startx = [];

  % Loop
  its    = 1;
  finish = 0;
  while ~finish
    % Remember old objective function value
    old_obj = obj;

    % Find the products and convert them to signs
    temp_s_k = sign(omega' * data + b); % 1 * n_data

    % Find the s_W
    s_W = diag(temp_s_k) * W; % n_data * n_constraints

    % Find the s_k
    s_k = temp_s_k * W / n_data; % 1 * n_constraints

    % Find the z_k
    z_k = data * s_W / n_data; % n_dims * n_constraints
    
    % Find the x_mat
    x_mat = [ z_k, -x_k, x_k ]; % n_dims * (n_constraints + 2)

    % Objective function
    H = x_mat' * x_mat; % (n_constraints + 2) * (n_constraints + 2)
    
    % Inequalities
    Aeq = [ -s_k, n_data, -n_data ]; % 1 * (n_constraints + 2)

    % Solve
    [ x, obj ] = qp(startx, H, f, Aeq, beq, lb, ub, blb, Ain, bub);

    % Invert
    obj = -obj;

    % Find primal variables
    omega = x_mat * x;
    xi    = (obj - 0.5 * omega' * omega) / C;
    SVs   = x(1 : n_constraints) > 0;
    if any(SVs)
      b   = mean((c_k(SVs) - xi - omega' * z_k(:, SVs)) ./ s_k(SVs));
    else
      b   = 0;
    end

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
      % Start from here
      startx = x;
    end

    % One more iteration
    its = its + 1;
  end

% Local Variables:
% mode:octave
% End:
