%% -*- mode: octave; -*-

%% Set a single seed to all random generators

%% Author: Edgar Gonzàlez i Pellicer

%% Set all seeds
function set_all_seeds(seed)
  %% Set each one
  rand ("seed", seed);
  randn("seed", seed);
endfunction
