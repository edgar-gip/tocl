%% -*- mode: octave; -*-

%% Knee-detection interpolator model
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = KneeInterModel(cut, low_model, high_model)

  %% Check arguments
  if nargin() ~= 3
    usage("[ this ] = KneeInterModel(cut, low_model, high_model)");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.cut        = cut;
  this.low_model  = low_model;
  this.high_model = high_model;

  %% Bless
  %% And add inheritance
  this = class(this, "KneeInterModel", ...
	       Simple());
endfunction
