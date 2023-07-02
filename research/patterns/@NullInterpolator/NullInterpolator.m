%% -*- mode: octave; -*-

%% Null interpolator
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = NullInterpolator()

  %% Check arguments
  if nargin() ~= 0
    usage("[ this ] = NullInterpolator()");
  endif

  %% This object
  this = struct();

  %% Bless
  %% And add inheritance
  this = class(this, "NullInterpolator", ...
               Simple());
endfunction
