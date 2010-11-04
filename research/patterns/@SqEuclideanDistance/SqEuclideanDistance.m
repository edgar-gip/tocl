%% -*- mode: octave; -*-

%% Squared Euclidean Distance
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = SqEuclideanDistance()

  %% Check arguments
  if nargin() ~= 0
    usage("[ this ] = SqEuclideanDistance()");
  endif

  %% Bless
  %% And add inheritance
  this = class(struct(), "SqEuclideanDistance", ...
	       Simple());
endfunction
