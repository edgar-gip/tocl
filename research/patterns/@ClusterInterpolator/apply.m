%% -*- mode: octave; -*-

%% Cluster interpolator
%% Apply function

%% Author: Edgar Gonzalez

function [ output, model, info ] = apply(this, input)

  %% Check arguments
  if nargin() ~= 2
    usage("[ output, model, info ] = @ClusterInterpolator/apply(this, input)");
  endif

  %% Apply clusterer
  [ cl_expec, cl_model, info ] = ...
      cluster(this.clusterer, input, this.total_k);

  %% Mapping matrix
  mapping = zeros(1, this.total_k);
  mapping(1, this.low_k + 1 : this.total_k) = 1;

  %% Apply it
  output = mapping * cl_expec;

  %% Model
  model = ClusterInterModel(cl_model, mapping);
endfunction
