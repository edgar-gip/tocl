%% -*- mode: octave; -*-

%% Ensemble Weak One-Class Scoring
%% Clustering function

function [ expec, model, info ] = cluster(this, data, k)

  %% this and data must be given
  if nargin() < 2 || nargin() > 3
    usage("[ expec, model, info ] = @EWOCS/cluster(this, data, k)");
  endif

  %% The number of clusters must be 2
  if nargin() == 3 && k ~= 2
    error("k must be 2 if given");
  endif

  %% Score them data
  [ scores, model, info ] = score(this, data);

  %% Interpolate scores
  [ expec, map_info ] = apply(this.interpolator, scores);

  %% Extend info with map_info
  for [ field, value ] = map_info
    info = setfield(info, field, value);
  endfor
endfunction
