%% -*- mode: octave; -*-

%% Harden an expectation

%% Author: Edgar Gonzalez

function [ hard, best_cl ] = harden_expectation(soft, add_bg = false())
  %% Size
  [ k, n_data ] = size(soft);

  %% Add a background component?
  if add_bg
    %% Find the background cluster probability
    bg_cl = 1.0 - sum(soft, 1);

    %% Add it
    soft = [ bg_cl ; soft ];

    %% One more cluster
    k += 1;
  endif

  %% Find best clusters
  [ best_soft, best_cl ] = max(soft);

  %% Convert to hard
  hard = sparse(best_cl, 1 : n_data, ones(1, n_data), k, n_data);
endfunction
