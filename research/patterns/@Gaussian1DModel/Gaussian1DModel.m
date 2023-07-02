%% -*- mode: octave; -*-

%% 1-D Gaussian distribution clustering
%% Model constructor

%% Author: Edgar Gonzalez

function [ this ] = Gaussian1DModel(k, alpha, mean, var)

  %% Check arguments
  if nargin() ~= 4
    usage("[ this ] = Gaussian1DModel(k, alpha, mean, var)");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.k     = k;
  this.alpha = alpha; % 1 * k
  this.mean  = mean;  % 1 * k
  this.var   = var;   % 1 * k

  %% Precalculated
  this.log_alpha_var = log(alpha) - 0.5 * log(var);

  %% Bless
  %% And add inheritance
  this = class(this, "Gaussian1DModel", ...
               Simple());
endfunction
