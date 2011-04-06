%% -*- mode: octave; -*-

%% k-Minority Detection
%% Model constructor

%% Author: Edgar Gonzalez

function [ this ] = KMDModel(log_alpha, components)

  %% Check arguments
  if nargin() ~= 2
    usage("[ this ] = KMDModel(log_alpha, components)");
  endif

  %% This object
  this = struct();

  %% Store fields
  this.log_alpha  = log_alpha;
  this.components = components;

  %% Bless
  %% And add inheritance
  this = class(this, "KMDModel", ...
	       Simple());
endfunction
