%% -*- mode: octave; -*-

%% Jensen-Shannon Divergence
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = JSDivergence()

  %% Check arguments
  if nargin() ~= 0
    usage("[ this ] = JSDivergence()");
  endif

  %% Bless
  %% And add inheritance
  this = class(struct(), "JSDivergence", ...
               Simple());
endfunction
