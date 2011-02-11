%% -*- mode: octave; -*-

%% k-Minority Detection

%% Multinomial Component Constructor

%% Author: Edgar Gonzalez

function [ this ] = KMDMultinomial(data)

  %% Check arguments
  if nargin() ~= 1
    usage("[ this ] = KMDMultinomial(data)");
  endif

  %% This object
  this = struct();

  %% Size
  [ n_dims, n_data ] = size(data);

  %% Store the number of dimensions
  this.n_dims = n_dims;

  %% Find the unnormalized thetas
  this.un_theta = sum(data, 2)';

  %% Find the total vocabulary size
  this.un_total = sum(this.un_theta);

  %% Find the log-thetas
  this.log_theta = log((1 + this.un_theta) / (this.n_dims + this.un_total));

  %% Bless
  %% And add inheritance
  this = class(this, "KMDMultinomial", ...
	       Simple());
endfunction
