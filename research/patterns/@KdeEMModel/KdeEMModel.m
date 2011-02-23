%% -*- mode: octave; -*-

%% Kernel Density Estimation EM clustering
%% Model constructor

%% Author: Edgar Gonzalez

function [ this ] = KdeEMModel(kernel, data, expec)

  %% Check arguments
  if nargin() ~= 3
    usage("[ this ] = KdeEMModel(kernel, data, expec)");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.kernel = kernel;
  this.data   = data;
  this.expec  = expec;
  this.k      = size(expec, 1);

  %% Bless
  %% And add inheritance
  this = class(this, "KdeEMModel", ...
	       Simple());
endfunction
