%% -*- mode: octave; -*-

%% Random clustering
%% Model constructor

%% Author: Edgar Gonzalez

function [ this ] = RandomModel(soft_alpha, projection)

  %% Check arguments
  if nargin() ~= 2
    usage("[ this ] = RandomModel(soft_alpha, projection)");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.soft_alpha = soft_alpha;
  this.projection = projection;

  %% Bless
  %% And add inheritance
  this = class(this, "RandomModel", ...
	       Simple());
endfunction
