%% -*- mode: octave; -*-

%% Multinomial distribution clustering
%% Model constructor

%% Author: Edgar Gonzalez

function [ this ] = MultinomialModel(k, alpha, theta)

  %% Check arguments
  if nargin() ~= 3
    usage("[ this ] = MultinomialModel(k, alpha, theta)");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.k     = k;
  this.alpha = alpha; % k * 1
  this.theta = theta; % k * n_dims

  %% Bless
  %% And add inheritance
  this = class(this, "MultinomialModel", ...
               Simple());
endfunction
