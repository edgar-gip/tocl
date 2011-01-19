%% -*- mode: octave; -*-

%% Truly random clustering
%% Model constructor

%% Author: Edgar Gonzalez

function [ this ] = RandomModel(concentration, k)

  %% Check arguments
  if nargin() ~= 2
    usage("[ this ] = RandomModel(concentration, k)");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.concentration = concentration;
  this.k             = k;

  %% Bless
  %% And add inheritance
  this = class(this, "RandomModel", ...
	       Simple());
endfunction
