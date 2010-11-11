%% -*- mode: octave; -*-

%% Cluster interpolator model
%% Apply function

%% Author: Edgar Gonzalez

function [ output ] = apply(this, input)

  %% Check arguments
  if nargin() ~= 2
    usage("[ output ] = @ClusterInterModel/apply(this, input)");
  endif

  %% Find the expectation
  expec = expectation(this.cl_model, input);

  %% Apply the mapping
  output = mapping * expec;
endfunction
