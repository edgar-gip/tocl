%% -*- mode: octave; -*-

%% Bayesian Information Criterion
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = BIC()

  %% Check arguments
  if nargin() ~= 0
    usage("[ this ] = BIC()");
  endif

  %% Bless
  %% And add inheritance
  this = class(struct(), "BIC", ...
	       Simple());
endfunction
