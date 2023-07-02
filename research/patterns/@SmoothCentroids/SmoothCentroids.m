%% -*- mode: octave; -*-

%% Smooth Centroid Finder
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = SmoothCentroids(data_term = 1, size_term = 2)

  %% Check arguments
  if ~any(nargin() == [ 0, 1, 2 ])
    usage("[ this ] = SmoothCentroids([ data_term [, size_term ]])");
  endif

  %% This
  this = struct();

  %% Smoothing terms
  this.data_term = data_term;
  this.size_term = size_term;

  %% Bless
  %% And add inheritance
  this = class(this, "SmoothCentroids", ...
               Simple());
endfunction
