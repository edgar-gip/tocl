%% -*- mode: octave; -*-

%% Ensemble Weak One-Class Scoring
%% Size Scoring Function Constructor

%% Author: Edgar Gonzalez

function [ this ] = SizeCSF()

  %% Bless
  %% And add inheritance
  this = class(struct(), "SizeCSF", ...
	       Simple());
endfunction
