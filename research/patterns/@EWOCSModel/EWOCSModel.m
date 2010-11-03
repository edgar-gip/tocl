%% -*- mode: octave; -*-

%% Ensemble Weak One-Class Scoring
%% Model Constructor

function [ this ] = EWOCSModel(models, cluster_scores)

  %% This object
  this = struct();

  %% Set fields
  this.models         = models;         % r
  this.cluster_scores = cluster_scores; % r * (k_r * 1)

  %% Bless
  %% And add inheritance
  this = class(this, "EWOCSModel", ...
	       Simple());
endfunction
