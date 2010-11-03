%% -*- mode: octave; -*-

%% Squared Euclidean Distance
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = SqEuclideanDistance()

  %% Bless
  %% And add inheritance
  this = class(struct(), "SqEuclideanDistance", ...
	       Simple());
endfunction
