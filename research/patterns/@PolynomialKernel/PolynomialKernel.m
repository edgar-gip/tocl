%% -*- mode: octave; -*-

%% Polynomial Kernel
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = PolynomialKernel(degree, heterogeneous = 0)

  %% Check arguments
  if ~any(nargin() == [ 1, 2 ])
    usage("[ this ] = PolynomialKernel(degree [, heterogeneous])");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.degree        = degree;
  this.heterogeneous = heterogeneous;

  %% Bless
  %% And add inheritance
  this = class(this, "PolynomialKernel", ...
	       Simple());
endfunction
