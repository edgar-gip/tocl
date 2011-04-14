%% -*- mode: octave; -*-

%% Logistic Loss
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = LogisticLoss()

  %% Check arguments
  if nargin() ~= 0
    usage("[ this ] = LogisticLoss()");
  endif

  %% Bless
  %% And add inheritance
  this = class(struct(), "LogisticLoss", ...
	       Simple());
endfunction
