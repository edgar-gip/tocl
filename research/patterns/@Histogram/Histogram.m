%% -*- mode: octave; -*-

%% Histogram
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = Histogram()

  %% Check arguments
  if nargin() ~= 0
    usage("[ this ] = Histogram()");
  endif

  %% Bless
  %% And add inheritance
  this = class(struct(), "Histogram", ...
               Simple());
endfunction
