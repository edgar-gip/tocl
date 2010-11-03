%% -*- mode: octave; -*-

%% Ensemble Weak One-Class Scoring
%% Model Constructor

function [ this ] = EWOCSModel(models, cluster_scores, interpolator)

  %% This object
  this = struct();

  %% Set fields
  this.models         = models;         % r
  this.cluster_scores = cluster_scores; % r * (k_r * 1)
  this.interpolator   = interpolator;

  %% Bless
  %% And add inheritance
  this = class(this, "EWOCSModel", ...
	       Simple());
endfunction
