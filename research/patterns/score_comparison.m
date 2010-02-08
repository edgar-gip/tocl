%% -*- mode: octave; -*-

%% Comparison of scores

%% Author: Edgar Gonzalez

function [ tests ] = score_comparison(scores, truth, sizes)
  %% Normalize scores
  nscores = score_normalize(scores);

  %% Find the two sets of scores
  nscores_a = nscores(full(truth(1,:) ~= 0));
  nscores_b = nscores(full(truth(2,:) ~= 0));

  %% Means and variances
  mean_all = mean(nscores);
  mean_a   = mean(nscores_a);
  var_a    = var (nscores_a);
  mean_b   = mean(nscores_b);
  var_b    = var (nscores_b);

  %% Sizes
  size_a = sizes(1);
  size_b = sizes(2);

  %% Student-t Test
  mean_t     = (mean_a - mean_b) / sqrt(var_a / size_a + var_b / size_b);
  mean_t_df  = ((var_a / size_a + var_b / size_b) ^ 2) / ...
               ((var_a / size_a) ^ 2 / (size_a - 1) + ... 
		(var_b / size_b) ^ 2 / (size_b - 1));
  mean_t_cdf = tcdf(mean_t, mean_t_df); % formerly t_cdf

  %% Rank
  ranks = matrix_rankize(scores);

  %% Mann-Whitney U test
  R       = truth * ranks';
  U       = min(R(1) - (size_a * (size_a - 1)) / 2, ...
		R(2) - (size_b * (size_b - 1)) / 2);
  U_z_cdf = normcdf(U, size_a * size_b / 2, ... % formerly normal_cdf
		    size_a * size_b * (size_a + size_b + 1) / 12);

  %% Join the tests
  tests = [ mean_all, mean_a, mean_b, mean_t_cdf, U, U_z_cdf ];
endfunction
