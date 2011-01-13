%% -*- mode: octave; -*-

%% Smoothed Kullback-Leibler Divergence
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = SmoothKLDivergence(term)

  %% Check arguments
  if nargin() ~= 1
    usage("[ this ] = SmoothKLDivergence(term)");
  endif

  %% This
  this = struct();

  %% Smoothing term
  this.term = term;

  %% Bless
  %% And add inheritance
  this = class(this, "SmoothKLDivergence", ...
	       Simple());
endfunction
