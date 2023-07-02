%% -*- mode: octave; -*-

%% RBF Kernel Generator
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = RBFKernelGenerator(min_rbf_gamma, max_rbf_gamma)

  %% Check arguments
  if nargin() ~= 2
    usage("[ this ] = RBFKernelGenerator(min_rbf_gamma, max_rbf_gamma)");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.min_rbf_gamma = min_rbf_gamma;
  this.max_rbf_gamma = max_rbf_gamma;

  %% Extra
  this.log_range = log(max_rbf_gamma / min_rbf_gamma);

  %% Bless
  %% And add inheritance
  this = class(this, "RBFKernelGenerator", ...
               Simple());
endfunction
