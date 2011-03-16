%% -*- mode: octave; -*-

%% Test different search strategies for mcd-shaped functions

%% Author: Edgar Gonzàlez i Pellicer


%% Octopus
pkg load octopus


%% The function
function [ z ] = evaluate(x, y, opts)
  %% First component
  z_x = 1 ./ (1 .+ exp(opts.alpha_x .* (opts.x_mid .- x)));

  %% Second component
  y_up   = opts.y_max .- (opts.y_max .- opts.y_mid) ./ ...
           exp(opts.alpha_xy * (x .- opts.x_mid));
  z_y_up = 1 ./ (1 .+ exp(opts.alpha_y .* (y .- y_up)));

  %% Third component
  y_dn   = opts.y_min .+ (opts.y_mid .- opts.y_min) ./ ...
           exp(opts.alpha_xy * (x .- opts.x_mid));
  z_y_dn = 1 ./ (1 .+ exp(opts.alpha_y .* (y_dn .- y)));

  %% The raw value is...
  z_raw = z_x .* z_y_up .* z_y_dn;

  %% Add noise
  z_n = opts.noise .* randn(size(z_raw));

  %% Add it
  z = max(0, z_raw .+ z_n);
endfunction


%% Evaluate in point form
function [ z ] = evaluate_p(p, opts)
  %% Evaluate
  x     = p(1, :);
  y     = p(2, :);
  z_raw = evaluate(x, y, opts);
  z     = log(1 + (z_raw - opts.target) .^ 2);

  %% Log
  %% fprintf(2, "x = %12g, y = %12g -> z = %12g (%12g)\n", ...
  %% 	  [ x' ; y' ; z_raw' ; z' ]);
endfunction


%% Value range
function [ r ] = value_range(x1, x2)
  r = 2.0 * abs(x1 - x2) / (abs(x1) + abs(x2) + eps);
endfunction


%% Compare two points
function [ cmp ] = compare_p(y1, p1, y2, p2, opts)
  %% Comparison?
  if opts.s_min_x && value_range(y1, y2) < opts.s_ftol
    %% Equal -> Compare the x value
    p1
    p2
    cmp = sign(p1(1) - p2(1))
  else
    %% Compare the functions
    cmp = sign(y1 - y2);
  endif
endfunction

%% Simplex helper function
function [ p, y, p_sum, y_try, p_try ] = ...
      simplex_try(p, y, p_sum, i_hi, fac, opts)
  %% Dimensions
  n_dims = size(p, 1);

  %% Factors
  fac_1 = (1 - fac) / n_dims;
  fac_2 = fac_1 - fac;

  %% Hi point
  p_hi  = p(:, i_hi);
  y_hi  = y(i_hi);

  %% Try point
  p_try = fac_1 * p_sum - fac_2 * p_hi;

  %% Evaluate
  y_try = evaluate_p(p_try, opts);

  %% Improved?
  if compare_p(y_try, p_try, y_hi, p_hi, opts) < 0 %% y_try < y_hi
    %% Update sum
    p_sum += (p_try - p_hi);

    %% Update
    y(i_hi)    = y_try;
    p(:, i_hi) = p_try;
  endif
endfunction


%% Nelder-Mead Simplex
%% Algorithm 10.5 from Numerical Recipes
function [ p_min ] = simplex(opts)
  %% Dimensions
  n_dims = 2;

  %% Generate a set of starting points
  p_0 = [ opts.s_x_0 ; opts.s_y_0 ];
  p   = [ p_0, repmat(p_0, 1, n_dims) + opts.s_delta * eye(n_dims) ];
  n_p = n_dims + 1;

  %% Evaluate the function at each one of them
  y = evaluate_p(p, opts);

  %% Plot the starting set
  h = plot(p(1, :), p(2, :), "*", "linewidth", 8);

  %% Point sum
  p_sum = sum(p, 2);

  %% Number of function evaluations
  n_eval = 0;

  %% Loop
  final = false();
  while ~final
    %% Find worst, best and next to best

    %% Starting values
    if compare_p(y(1), p(:, 1), y(2), p(:, 2), opts) > 0 %% y(1) > y(2)
      i_hi  = 1;
      i_nhi = 2;
      i_lo  = 2;
    else
      i_hi  = 2;
      i_nhi = 1;
      i_lo  = 1;
    endif

    %% For the rest...
    for i = 3 : n_p
      if compare_p(y(i), p(:, i), ...
		   y(i_lo), p(:, i_lo), opts) < 0 %% y(i) < y(i_lo)
	i_lo = i;
      endif

      if compare_p(y(i), p(:, i), ...
		   y(i_hi), p(:, i_hi), opts) > 0 %% y(i) > y(i_hi)
	i_nhi = i_hi;
	i_hi  = i;

      elseif compare_p(y(i), p(:, i), ...
		       y(i_nhi), p(:, i_nhi), opts) > 0 %% y(i) > y(i_nhi)
	i_nhi = i;
      endif
    endfor

    %% Range
    rtol = value_range(y(i_hi), y(i_lo));
    if rtol < opts.s_ftol || n_eval >= opts.s_max_eval
      %% Found a solution
      p_min = p(:, i_lo);
      final = true();

    else
      %% Extrapolate across the high point
      [ p, y, p_sum, y_try, p_try ] = ...
	  simplex_try(p, y, p_sum, i_hi, -1.0, opts);
      ++n_eval;

      %% What?
      if compare_p(y_try, p_try, ...
		   y(i_lo), p(:, i_lo), opts) < 0 %% y_try < y(i_lo)
	%% Try additional extrapolation
	[ p, y, p_sum ] = simplex_try(p, y, p_sum, i_hi, 2.0, opts);
	++n_eval;

      elseif compare_p(y_try, p_try, ...
		       y(i_nhi), p(:, i_nhi), opts) >= 0 %% y_try >= y(i_nhi)
	%% Look for an intermediate point
	y_save = y(i_nhi);
	p_save = p(:, i_nhi);
	[ p, y, p_sum, y_try, p_try ] = ...
	    simplex_try(p, y, p_sum, i_hi, 0.5, opts);
	++n_eval;

	%% What?
	if compare_p(y_try, p_try, ...
		     y_save, p_save, opts) >= 0 %% y_try >= y_save
	  %% Contract around the best point
	  is = 1 : n_p ~= i;
	  p(:, is) = (repmat(p(:, i_lo), 1, n_p - 1) + p(:, is)) / 2;

	  %% Eval
	  y(is)   = evaluate_p(p(:, is), opts);
	  n_eval += n_p - 1;

	  %% Update point sum
	  p_sum = sum(p, 2);
	endif
      endif

      %% Plot the simplex
      delete(h);
      h = plot(p(1, :), p(2, :), "k*", "linewidth", 4);
      replot();
    endif
  endwhile

  %% Plot the solution
  delete(h);
  h = plot(p_min(1, :), p_min(2, :), "r*", "linewidth", 8);
  replot();
endfunction


%% Options
def_opts          = struct();
def_opts.alpha_x  =  1.0;
def_opts.alpha_xy =  0.2;
def_opts.alpha_y  =  1.0;
def_opts.x_mid    =  0.0;
def_opts.y_min    = -5.0;
def_opts.y_mid    = +2.0;
def_opts.y_max    = +5.0;
def_opts.noise    =    0;

%% Target options
def_opts.target = 0.1;

%% Simplex options
def_opts.s_x_0      = 0;
def_opts.s_y_0      = 0;
def_opts.s_delta    = 2.0;
def_opts.s_max_eval = 1000;
def_opts.s_ftol     = 1e-3;
def_opts.s_min_x    = false();

%% Parse options
[ cmd_args, cmd_opts ] = ...
    get_options(def_opts, ...
		"alpha-x=f",  	"alpha_x",    ...
		"alpha-xy=f", 	"alpha_xy",   ...
		"alpha-y=f",  	"alpha_y",    ...
		"x-mid=f",    	"x_mid",      ...
		"y-min=f",    	"y_min",      ...
		"y-mid=f",    	"y_mid",      ...
		"y-max=f",    	"y_max",      ...
		"noise=f",    	"noise",      ...
		...
		"target=f",   	"target",     ...
		...
		"s-x-0=f",    	"s_x_0",      ...
		"s-y-0=f",    	"s_y_0",      ...
		"s-delta=f",  	"s_delta",    ...
		"s-max-eval=i", "s_max_eval", ...
		"s-ftol=f",     "s_ftol",     ...
		"s-min-x!",     "s_min_x");

%% Make a grid
%% (Just to test something)
x = -10 : .5 : 10;
y = -10 : .5 : 10;
[ xx, yy ] = meshgrid(x, y);
z = evaluate(xx, yy, cmd_opts);

%% Plot
hold on;

%% Contour
contour(x, y, z);
contour(x, y, z, [ cmd_opts.target, cmd_opts.target ], "linewidth", 2);
replot();

%% Simplex
[ p_simplex ] = simplex(cmd_opts);
printf("Solution: (%g, %g)\n", p_simplex);

%% Pause
pause();





