%% -*- mode: octave; -*-

%% Multinomial distribution clustering
%% Alpha values

%% Author: Edgar Gonzalez

function [ th ] = alpha(this, log_form = false())

  %% Check arguments
  if ~any(nargin() == [ 1, 2 ])
    usage("[ th ] = @MultinomialModel/alpha(this [, log_form])");
  endif

  %% Return alpha
  if log_form
    th = this.alpha;
  else
    th = exp(this.alpha);
  endif
endfunction
