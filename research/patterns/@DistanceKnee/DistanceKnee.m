%% -*- mode: octave; -*-

%% Distance Knee Finder
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = DistanceKnee()

  %% Check arguments
  if nargin() ~= 0
    usage("[ this ] = DistanceKnee()");
  endif

  %% This object
  this = struct();

  %% Bless
  %% And add inheritance
  this = class(this, "DistanceKnee", ...
	       Simple());
endfunction
