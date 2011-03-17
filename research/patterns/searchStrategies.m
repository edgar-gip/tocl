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
  z     = log(1 + (z_raw - opts.target) .^ 2) + ...
          opts.beta * atan(x - opts.x_beta) / pi;

  %% Log
  %% fprintf(2, "x = %12g, y = %12g -> z = %12g (%12g)\n", ...
  %% 	  [ x' ; y' ; z_raw' ; z' ]);
endfunction


%% Plot callback
function plot_cb(p, y, moment)
  %% Point handle
  persistent ph = [];

  %% When?
  switch moment
    case 0
      %% First one
      ph = plot(p(1, :), p(2, :), "k*", "linewidth", 4);

    case 1
      %% Iteration
      delete(ph);
      ph = plot(p(1, :), p(2, :), "k*", "linewidth", 4);

    case 2
      %% Final
      delete(ph);
      plot(p(1, :), p(2, :), "r*", "linewidth", 8);
      ph = [];
  endswitch

  %% Replot
  replot();
endfunction

%% Minimization
function [ p_simplex ] = simplex_minimize(p_0, opts)
  %% Create simplex object
  persistent simplex = ...
      NelderMead(struct("delta",     opts.s_delta,    ...
			"max_eval",  opts.s_max_eval, ...
			"tolerance", opts.s_ftol,     ...
			"callback",  @plot_cb));

  %% Set point
  p = p_0;

  %% Loop
  finish = false();
  while ~finish
    %% Set x_beta
    opts.x_beta = p(1);

    %% Solve
    p = minimize(simplex, @(x) evaluate_p(x, opts), p);

    %% Log
    fprintf("Step for beta = %g -> (%g, %g)\n", opts.x_beta, p);

    %% New x_beta?
    diff = abs(p(1) - opts.x_beta) / (abs(p(1)) + abs(opts.x_beta) + eps);
    if diff < opts.s_btol
      %% Converged
      p_simplex = p;
      finish = true;
    endif
  endwhile
endfunction


%% Options
def_opts          = struct();
def_opts.alpha_x  =  1.0;
def_opts.alpha_xy =  0.2;
def_opts.alpha_y  =  1.0;
def_opts.beta     =  0.01;
def_opts.x_mid    =  0.0;
def_opts.y_min    = -5.0;
def_opts.y_mid    = +2.0;
def_opts.y_max    = +5.0;
def_opts.noise    =    0;

%% Target options
def_opts.target = 0.1;

%% Grid options
def_opts.g_x_min = -10;
def_opts.g_x_max = +10;
def_opts.g_y_min = -10;
def_opts.g_y_max = +10;

%% Simplex options
def_opts.s_x_0      = 0;
def_opts.s_y_0      = 0;
def_opts.s_delta    = 2.0;
def_opts.s_max_eval = 1000;
def_opts.s_ftol     = 1e-3;
def_opts.s_btol     = 1e-3;

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
		"g-x-min=f",    "g_x_min",    ...
		"g-x-max=f",    "g_x_max",    ...
		"g-y-min=f",    "g_y_min",    ...
		"g-y-max=f",    "g_y_max",    ...
		...
		"s-x-0=f",    	"s_x_0",      ...
		"s-y-0=f",    	"s_y_0",      ...
		"s-delta=f",  	"s_delta",    ...
		"s-max-eval=i", "s_max_eval", ...
		"s-ftol=f",     "s_ftol",     ...
		"s-btol=f",     "s_btol");

%% Make a grid
%% (Just to test something)
x = cmd_opts.g_x_min : .5 : cmd_opts.g_x_max;
y = cmd_opts.g_y_min : .5 : cmd_opts.g_y_max;
[ xx, yy ] = meshgrid(x, y);
z = evaluate(xx, yy, cmd_opts);

%% Plot
hold on;

%% Contour
contour(x, y, z);
contour(x, y, z, [ cmd_opts.target, cmd_opts.target ], "linewidth", 2);
replot();

%% Event loop
final = false();
while ~final
  %% Get it
  [ x, y, button ] = ginput(1);

  %% What
  switch button
    case 1
      %% Find
      [ p_simplex ] = simplex_minimize([ x, y ]', cmd_opts);

      %% Log
      printf("(%g, %g) -> (%g, %g)\n", x, y, p_simplex);

    case -1
      %% End
      final = true();
  endswitch
endwhile

%% Pause
%% pause();
