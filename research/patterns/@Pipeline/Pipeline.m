%% -*- mode: octave; -*-

%% Pipeline of clustering methods
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = Pipeline(varargin)

  %% Check arguments
  if length(varargin) < 1
    usage("[ this ] = Pipeline(method [, method...])");
  endif

  %% This object
  this = struct();

  %% Methods
  this.methods = varargin;

  %% Bless
  %% And add inheritance
  this = class(this, "Pipeline", ...
               Simple());
endfunction
