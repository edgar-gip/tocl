%% -*- mode: octave; -*-

%% Random projection clustering
%% Model constructor

%% Author: Edgar Gonzalez

function [ this ] = RandomProjModel(soft_alpha, projection, bias)

  %% Check arguments
  if nargin() ~= 3
    usage("[ this ] = RandomProjModel(soft_alpha, projection, bias)");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.soft_alpha = soft_alpha;
  this.projection = projection;
  this.bias       = bias;

  %% Bless
  %% And add inheritance
  this = class(this, "RandomProjModel", ...
               Simple());
endfunction
