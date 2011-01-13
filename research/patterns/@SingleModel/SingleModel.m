%% -*- mode: octave; -*-

%% Single cluster
%% Model constructor

%% Author: Edgar Gonzalez

function [ this ] = SingleModel()

  %% Check arguments
  if nargin() ~= 0
    usage("[ this ] = SingleModel()");
  endif

  %% Bless
  %% And add inheritance
  this = class(struct(), "SingleModel", ...
	       Simple());
endfunction
