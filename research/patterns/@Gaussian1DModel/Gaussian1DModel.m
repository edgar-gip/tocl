%% -*- mode: octave; -*-

%% 1-D Gaussian distribution clustering
%% Model constructor

%% Author: Edgar Gonzalez

function [ this ] = Gaussian1DModel(k, alpha_var, mean, var)

  %% Check arguments
  if nargin() ~= 4
    usage("[ this ] = Gaussian1DModel(k, alpha_var, mean, var)");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.k         = k;
  this.alpha_var = alpha_var; % k * 1
  this.mean      = mean;      % k * 1
  this.var       = var;       % k * 1

  %% Bless
  %% And add inheritance
  this = class(this, "Gaussian1DModel", ...
	       Simple());
endfunction
