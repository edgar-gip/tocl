%% -*- mode: octave; -*-

%% Fake model (which stores a constant score vector)
%% Model constructor

%% Author: Edgar Gonzalez

function [ this ] = FakeModel(scores)

  %% Check arguments
  if nargin() ~= 1
    usage("[ this ] = FakeModel(scores)");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.scores = scores;

  %% Bless
  %% And add inheritance
  this = class(this, "FakeModel", ...
	       Simple());
endfunction
