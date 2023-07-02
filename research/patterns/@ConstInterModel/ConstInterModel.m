%% -*- mode: octave; -*-

%% Constant interpolator model
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = ConstInterModel(value_in, value)

  %% Check arguments
  if nargin() ~= 2
    usage("[ this ] = ConstInterModel(value_in, value)");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.value_in = value_in;
  this.value    = value;

  %% Bless
  %% And add inheritance
  this = class(this, "ConstInterModel", ...
               Simple());
endfunction
