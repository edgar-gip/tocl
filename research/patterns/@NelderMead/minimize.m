%% -*- mode: octave; -*-

%% Nelder-Mead Downhill Simplex in Multidimensions

%% Minimization function

%% Author: Edgar Gonzalez

function [ p_min, y_min ] = minimize(this, f, p_0)

  %% Check arguments
  if nargin() ~= 3
    error("Usage: [ p_min ] = @NelderMead/minimize(this, f, p_0)");
  endif

  %% Dimensions
  n_dims = size(p_0, 1);

  %% Generate a set of starting points
  p   = [ p_0, repmat(p_0, 1, n_dims) + this.delta * eye(n_dims) ];
  n_p = n_dims + 1;

  %% Number of function evaluations
  n_eval = 0;

  %% Evaluate the function at each one of them
  y = f(p); n_eval += n_p;

  %% Point sum
  p_sum = sum(p, 2);

  %% Callback
  if ~isempty(this.callback)
    this.callback(p, y, 0);
  endif

  %% Loop
  final = false();
  while ~final
    %% Find worst, best and next to best

    %% Starting values
    if y(1) > y(2)
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
      if y(i) < y(i_lo)
	i_lo = i;
      endif

      if y(i) > y(i_hi)
	i_nhi = i_hi;
	i_hi  = i;

      elseif y(i) > y(i_nhi)
	i_nhi = i;
      endif
    endfor

    %% Range
    rtol = 2.0 * abs(y(i_hi) - y(i_lo)) / (abs(y(i_hi)) + abs(y(i_lo)) + eps);

    %% Converged?
    if rtol < this.tolerance || n_eval >= this.max_eval
      %% Found a solution
      p_min = p(:, i_lo);
      y_min = y(i_lo);
      final = true();

    else
      %% Extrapolate across the high point
      [ p, y, p_sum, y_try, p_try ] = ...
	  simplex_try(f, p, y, p_sum, i_hi, -1.0);
      ++n_eval;

      %% What?
      if y_try < y(i_lo)
	%% Try additional extrapolation
	[ p, y, p_sum ] = simplex_try(f, p, y, p_sum, i_hi, 2.0);
	++n_eval;

      elseif y_try >= y(i_nhi)
	%% Look for an intermediate point
	y_save = y(i_nhi);
	p_save = p(:, i_nhi);
	[ p, y, p_sum, y_try, p_try ] = ...
	    simplex_try(f, p, y, p_sum, i_hi, 0.5);
	++n_eval;

	%% What?
	if y_try >= y_save
	  %% Contract around the best point
	  is = 1 : n_p ~= i;
	  p(:, is) = (repmat(p(:, i_lo), 1, n_p - 1) + p(:, is)) / 2;

	  %% Eval
	  y(is) = f(p(:, is)); n_eval += n_p - 1;

	  %% Update point sum
	  p_sum = sum(p, 2);
	endif
      endif

      %% Callback
      if ~isempty(this.callback)
	this.callback(p, y, 1);
      endif
    endif
  endwhile

  %% Callback
  if ~isempty(this.callback)
    this.callback(p_min, y_min, 2);
  endif
endfunction


%% Helper function
function [ p, y, p_sum, y_try, p_try ] = simplex_try(f, p, y, p_sum, i_hi, fac)
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
  y_try = f(p_try);

  %% Improved?
  if y_try < y_hi
    %% Update sum
    p_sum += (p_try - p_hi);

    %% Update
    y(i_hi)    = y_try;
    p(:, i_hi) = p_try;
  endif
endfunction
