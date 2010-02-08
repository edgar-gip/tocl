%% -*- mode: octave; -*-

%% Pearson correlation test

%% Author: Edgar Gonzalez

function [ rho, rho_t_cdf, rho_z_cdf ] = pearson_correlation(x, y)
  %% Size
  n_data = length(x);

  %% Variances and covariance
  var_x = var(x);
  var_y = var(y);
  covar = cov(x, y);

  %% Rho
  rho = covar / sqrt(var_x * var_y);

  %% Values
  if rho == 1
    %% Inf
    rho_t_cdf = 1.0;
    rho_z_cdf = 1.0;

  elseif rho == -1
    %% -Inf
    rho_t_cdf = 0.0;
    rho_z_cdf = 0.0;

  else
    %% Convert it to a student-t distributed variable
    rho_t     = rho / sqrt((1 - rho * rho) / (n_data - 2));
    rho_t_cdf = tcdf(rho_t, n_data - 2); % formerly t_cdf

    %% Convert it to a normal
    rho_z     = sqrt(n_data - 3) * 0.5 * log((1 + rho) / (1 - rho));
    rho_z_cdf = normcdf(rho_z, 0, 1); % formerly normal_cdf
  endif
endfunction
