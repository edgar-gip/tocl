%% -*- mode: octave; -*-

%% Simple class
%% Display function

%% Author: Edgar Gonzalez

function display(this)

  %% Check arguments
  if nargin() ~= 1
    usage("@Simple/display(this)");
  endif

  %% Display it
  fprintf("%s = %s<...>\n", inputname(1), class(this));
endfunction
