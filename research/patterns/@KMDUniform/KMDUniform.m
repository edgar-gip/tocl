%% -*- mode: octave; -*-

%% k-Minority Detection

%% Uniform Component Constructor

%% Author: Edgar Gonzalez

function [ this ] = KMDUniform(data)

  %% Check arguments
  if nargin() ~= 1
    usage("[ this ] = KMDUniform(data)");
  endif

  %% This object
  this = struct();

  %% Size
  [ n_dims, n_data ] = size(data);

  %% Probability
  this.log_p = -log(prod(max(data') - min(data')));

  %% Bless
  %% And add inheritance
  this = class(this, "KMDUniform", ...
               KMDComponent());
endfunction
