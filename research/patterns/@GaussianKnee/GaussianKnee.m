%% -*- mode: octave; -*-

%% Gaussian Knee Finder
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = GaussianKnee()

  %% Check arguments
  if nargin() ~= 0
    usage("[ this ] = GaussianKnee()");
  endif

  %% This object
  this = struct();

  %% Clusterer
  this.clusterer = Gaussian1D();

  %% Bless
  %% And add inheritance
  this = class(this, "GaussianKnee", ...
               Simple());
endfunction
