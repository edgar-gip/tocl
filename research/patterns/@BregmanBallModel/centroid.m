%% -*- mode: octave; -*-

%% Bregman Ball clustering
%% Centroid accessor

%% Author: Edgar Gonzalez

function [ c ] = centroid(this);

  %% Check arguments
  if nargin() ~= 1
    usage("[ c ] = centroid(this)");
  endif

  %% Return the centroid
  c = this.centroid;
endfunction

