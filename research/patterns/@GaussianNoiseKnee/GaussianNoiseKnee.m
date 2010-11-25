%% -*- mode: octave; -*-

%% Gaussian Knee Finder (with noise)
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = GaussianNoiseKnee()

  %% Check arguments
  if nargin() ~= 0
    usage("[ this ] = GaussianNoiseKnee()");
  endif

  %% This object
  this = struct();

  %% Clusterer
  this.clusterer = Gaussian1DNoise();

  %% Bless
  %% And add inheritance
  this = class(this, "GaussianNoiseKnee", ...
	       Simple());
endfunction
