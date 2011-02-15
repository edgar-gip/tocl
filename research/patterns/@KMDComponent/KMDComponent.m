%% -*- mode: octave; -*-

%% k-Minority Detection

%% Generic Component Constructor

%% Author: Edgar Gonzalez

function [ this ] = KMDComponent()

  %% Check arguments
  if nargin() ~= 0
    usage("[ this ] = KMDCompoenent()");
  endif

  %% Bless
  %% And add inheritance
  this = class(struct(), "KMDComponent", ...
	       Simple());
endfunction
