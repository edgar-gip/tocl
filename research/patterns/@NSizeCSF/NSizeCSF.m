%% -*- mode: octave; -*-

%% Ensemble Weak One-Class Scoring
%% Normalized Size Scoring Function Constructor

%% Author: Edgar Gonzalez

function [ this ] = NSizeCSF()

  %% Check arguments
  if nargin() ~= 0
    usage("[ this ] = NSizeCSF()");
  endif

  %% Bless
  %% And add inheritance
  this = class(struct(), "NSizeCSF", ...
	       Simple());
endfunction
