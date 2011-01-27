%% -*- mode: octave; -*-

%% Gaussian Knee Finder
%% Apply function

%% Author: Edgar Gonzalez

function [ mid, mid_idx ] = apply(this, input)

  %% Check arguments
  if nargin() ~= 2
    usage("[ mid, mid_idx ] = @GaussianKnee/apply(this, input)");
  endif

  %% Model
  [ expec, model ] = cluster(this.clusterer, input, 2);

  %% Sort the clusters
  [ sorted_mns, sorted_cl ] = sort(means(model), "descend");

  %% Cut point
  expec_tru = expec(sorted_cl(1), :);
  mid_idx   = last_downfall(expec_tru, 0.5);

  %% Any?
  if isempty(mid_idx)
    %% Failback
    mid_idx = 1;
  endif

  %% Cut value
  mid = input(mid_idx);
endfunction
