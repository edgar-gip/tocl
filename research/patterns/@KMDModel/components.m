%% -*- mode: octave; -*-

%% k-Minority Detection
%% Model
%% Components

%% Author: Edgar Gonzalez

function [ cs ] = components(this)

  %% Check arguments
  if nargin() ~= 1
    usage("[ cs ] = @KMDModel/components(this)");
  endif

  %% Return components
  cs = this.components;
endfunction
