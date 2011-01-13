%% -*- mode: octave; -*-

%% Kullback-Leibler Divergence
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = KLDivergence()

  %% Check arguments
  if nargin() ~= 0
    usage("[ this ] = KLDivergence()");
  endif

  %% Bless
  %% And add inheritance
  this = class(struct(), "KLDivergence", ...
	       Simple());
endfunction
