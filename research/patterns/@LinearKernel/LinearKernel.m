%% -*- mode: octave; -*-

%% Ensemble Weak One-Class Scoring
%% Linear Kernel Constructor

%% Author: Edgar Gonzalez

function [ this ] = LinearKernel()

  %% Bless
  %% And add inheritance
  this = class(struct(), "LinearKernel", ...
	       Simple());
endfunction
