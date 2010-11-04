%% -*- mode: octave; -*-

%% Simple class
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = Simple()

  %% Check arguments
  if nargin() ~= 0
    usage("[ this ] = Simple()");
  endif

  %% Bless
  this = class(struct(), "Simple");
endfunction
