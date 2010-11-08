%% -*- mode: octave; -*-

%% Mahalanobis Distance
%% Update

%% Author: Edgar Gonzalez

function [ this ] = update(this, data)

  %% Check arguments
  if nargin() ~= 2
    usage("[ this ] = update(this, data)");
  endif

  %% Inverse covariance
  this.data_invc = inverse(cov(data'));
endfunction
