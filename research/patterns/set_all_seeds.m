%% -*- mode: octave; -*-

%% Set a single seed to all random generators

%% Author: Edgar Gonz�lez i Pellicer

%% Set all seeds
function set_all_seeds(seed)
  %% Set each one
  rand ("seed", seed);
  randn("seed", seed);
endfunction
