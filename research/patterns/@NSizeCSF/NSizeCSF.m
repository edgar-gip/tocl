%% -*- mode: octave; -*-

%% Ensemble Weak One-Class Scoring
%% Normalized Size Scoring Function Constructor

%% Author: Edgar Gonzalez

function [ this ] = NSizeCSF()

  %% Bless
  %% And add inheritance
  this = class(struct(), "NSizeCSF", ...
	       Simple());
endfunction
