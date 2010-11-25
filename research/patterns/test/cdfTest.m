%% -*- mode: octave; -*-

%% Repeats
args = argv();
if length(args) == 0
  repeats = 10;
else
  repeats = str2double(args{1});
endif

%% Generate several examples
for r = 1 : repeats
  %% Select the two fractions
  %% alpha_1 = 0.5 + 0.5 * rand(1);
  alpha_1 = 0.6 + 0.35 * rand(1);
  alpha_2 = 1 - alpha_1;

  %% Select the two means
  mu_1 = -5.0;
  mu_2 = +5.0;

  %% Select the two variances
  prc_1 = gamrnd(2, 1 / 25.0); var_1 = 1 / prc_1; stdev_1 = sqrt(var_1);
  prc_2 = gamrnd(2, 1 / 15.0); var_2 = 1 / prc_2; stdev_2 = sqrt(var_2);

  %% Data range
  x_low = floor(10.0 * (mu_1 - 2 * stdev_1)) / 10.0;
  x_hi  =  ceil(10.0 * (mu_2 + 2 * stdev_2)) / 10.0;
  x = x_low : .1 : x_hi;

  %% Expectation (As raw log-probs)
  expec = [ log(alpha_1) - 0.5 * log(2 * pi * var_1) ...
                - ((x - mu_1) .^ 2) / (2 * var_1) ;
	    log(alpha_2) - 0.5 * log(2 * pi * var_2) ...
	        - ((x - mu_2) .^ 2) / (2 * var_2) ];

  %% Normalize
  max_expec = max(expec);
  sum_expec = max_expec .+ log(sum(exp(expec .- ones(2, 1) * max_expec)));
  expec     = exp(expec .- ones(2, 1) * sum_expec);

  %% Change point
  expec_idx = min(find(expec(2, :) >= 0.5));

  %% Analytical change point
  A = var_2 - var_1;
  B = 2 * (var_1 * mu_2 - var_2 * mu_1);
  C = var_2 * mu_1 * mu_1 - var_1 * mu_2 * mu_2 ...
      - 2 * var_1 * var_2 * log((alpha_1 / stdev_1) / (alpha_2 / stdev_2));

  %% Discriminate
  Delta = B * B - 4 * A * C;
  if Delta >= 0
    %% Solve
    sDelta = sqrt(Delta);
    an     = (-B + [ -sDelta, sDelta ]) / (2 * A);

    %% Restrict to range
    an = an(x_low <= an & an <= x_hi);

    %% Find cdf
    an_cdf = alpha_1 * normcdf(an, mu_1, stdev_1) + ...
	     alpha_2 * normcdf(an, mu_2, stdev_2);
  else
    %% No!
    an     = [];
    an_cdf = [];
  endif

  %% Cdf
  cdf_1 = normcdf(x, mu_1, stdev_1);
  cdf_2 = normcdf(x, mu_2, stdev_2);
  cdf   = alpha_1 * cdf_1 + alpha_2 * cdf_2;

  %% Generate some samples
  n_samples = 1000;
  rnd_data  = [ normrnd(mu_1, stdev_1, 1, n_samples) ;
	        normrnd(mu_2, stdev_2, 1, n_samples) ];
  selector  = 1 + (rand(1, n_samples) > alpha_1);
  rnd_data  = full(sum(rnd_data .* sparse(selector, 1 : n_samples, ...
					  ones(1, n_samples)), 1));
  sort_rnd_data = sort(rnd_data);

  %% Cut
  map_data = (sort_rnd_data - sort_rnd_data(1)) / ...
             (sort_rnd_data(n_samples) - sort_rnd_data(1));
  distance = map_data .^ 2 + (((n_samples - 1) : -1 : 0) / (n_samples - 1)).^ 2;
  [ min_dist, dist_idx ] = min(distance);

  %% Window
  figure();
  title(sprintf("%.3f * N(%.3f, %.3f) + %.3f * N(%.3f, %.3f)", ...
		alpha_1, mu_1, var_1, alpha_2, mu_2, var_2));

  %% First plot
  subplot(1, 2, 1);
  plot(x, expec(1, :), "-;p(y1 | x);", ...
       x, expec(2, :), "-;p(y2 | x);", ...
       x, cdf_1,       "-;F(x | y1);", ...
       x, cdf_2,       "-;F(x | y2);", ...
       x, cdf,         "-;F(x);", ...
       x(expec_idx), cdf(expec_idx), "*;Expec;", ...
       an, an_cdf,     "*;An-Expec;", ...
       [ x_low, x_hi ], [ alpha_1, alpha_1 ], "-;Alpha;");

  %% Second plot
  subplot(1, 2, 2);
  plot(cdf, x, "-;F(x);", ...
       an_cdf, an, "*;An-Expec;", ...
       (1 : n_samples) / n_samples, sort_rnd_data, "-;Data;", ...
       dist_idx / n_samples, sort_rnd_data(dist_idx), "*;Dist-Cut;");
endfor

%% Pause
pause;
