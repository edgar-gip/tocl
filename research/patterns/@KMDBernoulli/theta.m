%% -*- mode: octave; -*-

%% k-Minority Detection

%% Bernoulli Component Theta Values

%% Author: Edgar Gonzalez

function [ th ] = theta(this, clog_form = false())

  %% Check arguments
  if ~any(nargin() == [ 1, 2 ])
    usage("[ th ] = @KMDBernoulli/theta(this [, clog_form])");
  endif

  %% Return theta
  if clog_form
    th = this.clog_theta;
  else
    exp_clog = exp(this.clog_theta);
    th       = exp_clog ./ (1 + exp_clog);
  endif
endfunction
