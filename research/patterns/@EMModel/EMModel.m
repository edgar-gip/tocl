%% -*- mode: octave; -*-

%% Expectation-Maximization clustering
%% Model constructor

%% Author: Edgar Gonzalez

function [ this ] = EMModel()

  %% Check arguments
  if nargin() ~= 0
    usage("[ this ] = EMModel()");
  endif

  %% This object
  this = struct();

  %% Bless
  %% And add inheritance
  this = class(this, "EMModel", ...
               Simple());
endfunction
