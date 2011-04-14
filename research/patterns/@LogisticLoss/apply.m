%% -*- mode: octave; -*-

%% Logistic Loss
%% Distance

%% Author: Edgar Gonzalez

function [ dists ] = apply(this, source, target)

  %% Check arguments
  if ~any(nargin() == [ 2, 3 ])
    usage("[ dists ] = @LogisticLoss/apply(this, source [, target])");
  endif

  %% Call helper functions
  if nargin() == 2
    dists = logistic_loss1(source);
  else %% nargin() == 3
    dists = logistic_loss2(source, target);
  endif
endfunction
