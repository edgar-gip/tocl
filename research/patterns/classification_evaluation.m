%% -*- mode: octave; -*-

%% Classification evaluation

%% Author: Edgar Gonzalez

function [ purity, ipurity, f1, co_occ ] = ...
  classification_evaluation(system, truth)
  %% Find the co-occurrence matrix
  co_occ = system * truth'; % n_system * n_truth
  total  = sum(sum(co_occ));

  %% Maximum accross the system clusters
  purity = sum(max(co_occ')) / total;

  %% Maximum accross the true clusters
  ipurity = sum(max(co_occ)) / total;

  %% F1
  if purity > 0.0 || ipurity > 0.0
    f1 = 2 * purity * ipurity / (purity + ipurity);
  else
    f1 = 0.0;
  endif
endfunction
