%% -*- mode: octave; -*-

%% Mahalanobis Distance
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = MahalanobisDistance(data)

  %% Check arguments
  if nargin() ~= 1
    usage("[ this ] = MahalanobisDistance(data)");
  endif

  %% This
  this = struct();

  %% Inverse covariance
  this.data_invc = inverse(cov(data'));

  %% Bless
  %% And add inheritance
  this = class(this, "MahalanobisDistance", ...
               Simple());
endfunction
