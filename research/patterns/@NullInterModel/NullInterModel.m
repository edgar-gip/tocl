%% -*- mode: octave; -*-

%% Null interpolator model
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = NullInterModel()

  %% Check arguments
  if nargin() ~= 0
    usage("[ this ] = NullInterModel()");
  endif

  %% This object
  this = struct();

  %% Bless
  %% And add inheritance
  this = class(this, "NullInterModel", ...
               Simple());
endfunction
