%% -*- mode: octave; -*-

%% k-Minority Detection

%% Multinomial Component Theta Values

%% Author: Edgar Gonzalez

function [ th ] = theta(this, log_form = false())

  %% Check arguments
  if ~any(nargin() == [ 1, 2 ])
    usage("[ th ] = @KMDMultinomial/theta(this [, log_form])");
  endif

  %% Return theta
  if log_form
    th = this.log_theta;
  else
    th = exp(this.log_theta);
  endif
endfunction
