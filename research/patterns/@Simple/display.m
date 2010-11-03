%% -*- mode: octave; -*-

%% Simple class
%% Display function

%% Author: Edgar Gonzalez

function display(this)

  %% Display it
  fprintf("%s = %s<...>\n", inputname(1), class(this));
endfunction
