%% -*- mode: octave; -*-

%% Raw Centroid Finder
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = RawCentroids()

  %% Check arguments
  if nargin() ~= 0
    usage("[ this ] = RawCentroids()");
  endif

  %% Bless
  %% And add inheritance
  this = class(struct(), "RawCentroids", ...
               Simple());
endfunction
