%% -*- mode: octave; -*-

%% Smoothed Kullback-Leibler Divergence
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = SmoothKLDivergence(src_term, tgt_term = src_term)

  %% Check arguments
  if ~any(nargin() == [ 1, 2 ])
    usage("[ this ] = SmoothKLDivergence(src_term [, tgt_term])");
  endif

  %% This
  this = struct();

  %% Smoothing terms
  this.src_term = src_term;
  this.tgt_term = tgt_term;

  %% Bless
  %% And add inheritance
  this = class(this, "SmoothKLDivergence", ...
	       Simple());
endfunction
