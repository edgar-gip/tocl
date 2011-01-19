%% -*- mode: octave; -*-

%% Random projection clustering
%% Model constructor

%% Author: Edgar Gonzalez

function [ this ] = RandomProjModel(soft_alpha, projection)

  %% Check arguments
  if nargin() ~= 2
    usage("[ this ] = RandomProjModel(soft_alpha, projection)");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.soft_alpha = soft_alpha;
  this.projection = projection;

  %% Bless
  %% And add inheritance
  this = class(this, "RandomProjModel", ...
	       Simple());
endfunction
