%% -*- mode: octave; -*-

%% Multinomial distribution clustering
%% Theta values

%% Author: Edgar Gonzalez

function [ th ] = theta(this, log_form = false())

  %% Check arguments
  if ~any(nargin() == [ 1, 2 ])
    usage("[ this ] = @MultinomialModel/theta(this [, log_form])");
  endif

  %% Return theta
  if log_form
    th = this.theta;
  else
    th = exp(this.theta);
  endif
endfunction
