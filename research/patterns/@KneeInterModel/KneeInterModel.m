%% -*- mode: octave; -*-

%% Knee-detection interpolator model
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = KneeInterModel(mid, mid_in, low_model, high_model)

  %% Check arguments
  if nargin() ~= 4
    usage(cstrcat("[ this ] = KneeInterModel(mid, mid_in,",
                  " high_in, low_model, high_model)"));
  endif

  %% This object
  this = struct();

  %% Set fields
  this.mid        = mid;
  this.mid_in     = mid_in;
  this.low_model  = low_model;
  this.high_model = high_model;

  %% Bless
  %% And add inheritance
  this = class(this, "KneeInterModel", ...
               Simple());
endfunction
