%% -*- mode: octave; -*-

%% k-Minority Detection
%% Model
%% Alpha values

%% Author: Edgar Gonzalez

function [ al ] = alpha(this, log_form = false())

  %% Check arguments
  if ~any(nargin() == [ 1, 2 ])
    usage("[ al ] = @KMDModel/alpha(this [, log_form])");
  endif

  %% Return alpha
  if log_form
    al = this.log_alpha;
  else
    al = exp(this.log_alpha);
  endif
endfunction
