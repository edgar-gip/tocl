%% Cutting Plane Maximum Margin Clustering Algorithm (CPMMC)
%% Inner CCCP procedure

%% Author: Edgar Gonzalez

%% Based in CCCP_MMC_dual.m
%% Author: Bin Zhao

function [ omega, b, xi, obj, its ] = ...
      CPMMC_CCCP(data, omega, b, xi, W, C, l, per_quit, sum_data, avg_W, ...
		 iterations, violation, verbose);

  %% Sizes
  [ n_data, n_constraints ] = size(W);
  [ n_dims,          temp ] = size(omega);

  %% Starting objective function value
  obj = CPM3C_cost(omega, xi, C);
  
  %% Display
  if verbose
    if rem(iterations + 1, 10) == 0
      fprintf(2, "+ %6d %4d %8g %8g %8g\n", iterations + 1, n_constraints, ...
	      obj, xi, violation);
    else
      fprintf(2, "+");
    end
  end

  %% Objective function
  %% \sum_{j=1}^m \omega_j^2 + C \cdot \xi
  H = [ eye(n_dims) , zeros(n_dims, 2) ; zeros(2, n_dims + 2) ];
  f = [ zeros(n_dims + 1, 1) ; C ];

  %% Inequalities
  %% -l \leq \sum_{i=1}^n ( \sum_{j=1}^m w_j \cdot x_{ij} + b ) =
  %%       = \sum_{j=1}^m ( \sum_{i=1}^n x_{ij} ) \cdot w_j + n \cdot b \leq l
  %% \forall l \in \{ 1 \dots \Omega \}
  %%   \frac{1}{n} \sum_{i=1}^n c_{li} \leq
  %%   \sum_{j=1}^m \omega_j \cdot ( \frac{1}{n} \sum_{i=1}^n c_{li} \cdot 
  %%                                 s_{i} \cdot x_{ij} ) +
  %%   + b \cdot ( \frac{1}{n} \sum_{i=1}^n c_{li} \cdot s_{i} ) + \xi
  %% (The central part of Ain has to be filled)
  Ain = [ sum_data', n_data, 0 ;
	  zeros(n_constraints, n_dims + 1) , ones(n_constraints, 1) ];
  blb = [ -l; avg_W' ];
  bub = [ +l; inf * ones(n_constraints, 1) ];

  %% Equalities
  Aeq = [];
  beq = [];

  %% Ranges
  %% \xi \geq 0
  lb = [ -inf * ones(n_dims + 1, 1) ; 0 ];
  ub =    inf * ones(n_dims + 2, 1);

  %% Starting value
  startx = [ omega ; b ; xi ];

  %% Loop
  its    = 1;
  finish = 0;
  while ~finish
    %% Remember old objective function value
    old_obj = obj;

    %% Find the products and convert them to signs
    %% sk :: 1 * n_data
    %% sk_{i} = \sign(\sum_{j=1}^m \omega_j \cdot x_{ij} + b)
    sk = sign(omega' * data + b); 

    %% Multiply by each constraint
    %% sW :: n_data * n_constraints 
    %% sW_{il} = \frac{1}{n} c_{li} \cdot 
    %%                       sign(\sign(\sum_{j=1}^m \omega_j \cdot x_{ij} + b))
    sW = diag(sk) * W / n_data;

    %% Create the inequalities
    Ain(2 : n_constraints + 1, 1 : n_dims) = full(data * sW)';
    Ain(2 : n_constraints + 1, n_dims + 1) = sum(sW, 1)';
   
    %% Solve
    [ x, obj ] = qp(startx, H, f, Aeq, beq, lb, ub, blb, Ain, bub);

    %% Unpack
    omega = x(1 : n_dims);
    b     = x(n_dims + 1);
    xi    = x(n_dims + 2);

    %% Display
    if verbose
      if rem(iterations + its + 1, 10) == 0
	fprintf(2, ". %6d %4d %8g %8g %8g\n", iterations + its + 1, ...
		n_constraints, obj, xi, violation);
      else
	fprintf(2, ".");
      end
    end

    %% Finish?
    if old_obj - obj >= 0 && old_obj - obj < per_quit * old_obj
      %% Finish!
      finish = 1;
    else
      %% Start from here
      startx = x;
    end

    %% One more iteration
    its = its + 1;
  end

%% Local Variables:
%% mode:octave
%% End:
