%% -*- mode: octave; -*-

%% Ensemble Weak One-Class Scoring
%% RBF Kernel Constructor

%% Author: Edgar Gonzalez

function [ this ] = RBFKernel(rbf_gamma)

  %% rbf_gamma must be given
  if nargin() ~= 1
    usage("[ this ] = RBFKernel(rbf_gamma)");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.rbf_gamma = rbf_gamma;

  %% Bless
  %% And add inheritance
  this = class(this, "RBFKernel", ...
	       Simple());
endfunction
