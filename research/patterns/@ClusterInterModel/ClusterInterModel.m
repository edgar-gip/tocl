%% -*- mode: octave; -*-

%% Cluster interpolator model
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = ClusterInterModel(cl_model, mapping)

  %% Check arguments
  if nargin() ~= 2
    usage("[ this ] = ClusterInterModel(cl_model, mapping)");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.cl_model = cl_model;
  this.mapping  = mapping;

  %% Bless
  %% And add inheritance
  this = class(this, "ClusterInterModel", ...
	       Simple());
endfunction
