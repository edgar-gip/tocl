%% -*- mode: octave; -*-

%% Normalization of scores

%% Author: Edgar Gonzalez

function [ nscore ] = score_normalize(score)

  %% Find  minimum and maximum
  min_sc = min(score);
  max_sc = max(score);
  if min_sc == max_sc
    nscore = zeros(size(score));
  else
    nscore = (score - min_sc) ./ (max_sc - min_sc);
  endif
endfunction
