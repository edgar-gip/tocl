%% -*- mode: octave; -*-

%% Hyper Batch Ball One-Class Clustering
%% From:
%%   Gunjan Gupta, Joydeep Gosh
%%   "Robust One-Class Clustering using Hybrid Global and Local Search"
%%   International Conference on Machine Learning (ICML), 2005

%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = HyperBB(divergence, opts = struct())

  %% Check arguments
  if ~any(nargin() == [ 1, 2 ])
    usage("[ this ] = HyperBB(divergence [, opts])");
  endif

  %% This object
  this = struct();

  %% HOCC and BBOCC clusterers
  this.hocc  = HOCC (divergence, opts);
  this.bbocc = BBOCC(divergence, opts);

  %% Bless
  %% And add inheritance
  this = class(this, "HyperBB", ...
               Simple());
endfunction
