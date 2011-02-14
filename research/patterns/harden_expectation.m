%% -*- mode: octave; -*-

%% Harden an expectation

%% Author: Edgar Gonzalez

function [ hard ] = harden_expectation(soft, add_bg = false())
  %% Size
  [ k, n_data ] = size(soft);

  %% Add a background component?
  if add_bg
    %% Find the background cluster
    bg_cl = find(~sum(soft));
    n_bg  = length(bg_cl);

    %% Add it
    soft = [ sparse(1, bg_cl, ones(1, n_bg), 1, n_data) ; soft ];

    %% One more cluster
    k += 1;
  endif

  %% Find best clusters
  [ best_soft, best_cl ] = max(soft);

  %% Convert to hard
  hard = sparse(best_cl, 1 : n_data, ones(1, n_data), k, n_data);
endfunction
