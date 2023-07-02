%% -*- mode: octave; -*-

%% Cosine Distance
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = CosineDistance()

  %% Check arguments
  if nargin() ~= 0
    usage("[ this ] = CosineDistance()");
  endif

  %% Bless
  %% And add inheritance
  this = class(struct(), "CosineDistance", ...
               Simple());
endfunction
