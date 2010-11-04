%% -*- mode: octave; -*-

%% Constant interpolator model
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = ConstInterModel(value)

  %% Check arguments
  if nargin() ~= 1
    usage("[ this ] = ConstInterModel(value)");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.value = value;

  %% Bless
  %% And add inheritance
  this = class(this, "ConstInterModel", ...
	       Simple());
endfunction
