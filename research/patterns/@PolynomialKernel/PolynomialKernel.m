%% -*- mode: octave; -*-

%% Ensemble Weak One-Class Scoring
%% Polynomial Kernel Constructor

%% Author: Edgar Gonzalez

function [ this ] = PolynomialKernel(degree, homogeneous)

  %% degree and homogeneous must be given
  if nargin() ~= 2
    usage("[ this ] = PolynomialKernel(degree, homogeneous)");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.degree      = degree;
  this.homogeneous = homogeneous;

  %% Bless
  %% And add inheritance
  this = class(this, "PolynomialKernel", ...
	       Simple());
endfunction
