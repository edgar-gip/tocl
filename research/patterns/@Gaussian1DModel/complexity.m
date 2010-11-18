%% -*- mode: octave; -*-

%% 1-D Gaussian distribution clustering
%% Complexity

%% Author: Edgar Gonzalez

function [ c ] = complexity(this)

  %% Check arguments
  if nargin() ~= 1
    usage("[ c ] = @GaussianModel/complexity(this)");
  endif

  %% Number of free parameters
  %% (this.k - 1) -> Alpha
  %% this.k       -> Means
  %% this.k       -> Variances
  c = 3 * this.k - 1;
endfunction
