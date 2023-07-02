%% -*- mode: octave; -*-

%% Ensemble Weak One-Class Scoring
%% Size Scoring Function Constructor

%% Author: Edgar Gonzalez

function [ this ] = SizeCSF()

  %% Check arguments
  if nargin() ~= 0
    usage("[ this ] = SizeCSF()");
  endif

  %% Bless
  %% And add inheritance
  this = class(struct(), "SizeCSF", ...
               Simple());
endfunction
