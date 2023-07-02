%% -*- mode: octave; -*-

%% Evolution of scores

%% Author: Edgar Gonzalez

function [ tests ] = score_evolution(score_a, score_b)
  %% Size
  n_data = length(score_a);

  %% Empty?
  if n_data == 0
    tests = NaN * ones(1, 8);

  else
    %% Normalize scores
    nscore_a = score_normalize(score_a);
    nscore_b = score_normalize(score_b);

    %% Sum of normalized squares
    nsq   = (nscore_a - nscore_b);
    s_nsq = sum(nsq .* nsq);
    a_nsq = s_nsq / n_data;

    %% Pearson correlation
    [ rho, rho_t_pdf, rho_z_pdf ] = pearson_correlation(nscore_a, nscore_b);

    %% Ranks
    ranks_a = matrix_rankize(score_a);
    ranks_b = matrix_rankize(score_b);

    %% Normalized sum of rank squares
    rsq    = (ranks_a - ranks_b);
    s_rsq  = sum(rsq .* rsq);
    na_rsq = s_rsq / (n_data * n_data);

    %% Spearman correlation
    %% spearman = 1 - 6 * s_rsq / (n_data * (n_data * n_data - 1));

    %% Pearson correlation on ranks
    [ rk_rho, rk_rho_t_pdf, rk_rho_z_pdf ] = ...
        pearson_correlation(ranks_a, ranks_b);

    %% Join the tests
    tests = [ a_nsq, rho, rho_t_pdf, rho_z_pdf, ...
             na_rsq, rk_rho, rk_rho_t_pdf, rk_rho_z_pdf ];
  endif
endfunction
