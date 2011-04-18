%% -*- mode: octave; -*-

%% Multinomial Centroid Finder
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = MultinomialCentroids(data_term = 1)

  %% Check arguments
  if ~any(nargin() == [ 0, 1 ])
    usage("[ this ] = MultinomialCentroids([data_term])");
  endif

  %% This
  this = struct();

  %% Multinomialing terms
  this.data_term = data_term;

  %% Bless
  %% And add inheritance
  this = class(this, "MultinomialCentroids", ...
	       Simple());
endfunction
