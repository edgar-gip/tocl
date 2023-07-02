%% -*- mode: octave; -*-

%% Ensemble Weak One-Class Scoring
%% Model Constructor

%% Author: Edgar Gonzalez

function [ this ] = EWOCSModel(models, cluster_scores, inter_model)

  %% Check arguments
  if nargin() ~= 3
    usage("[ this ] = EWOCSModel(models, cluster_scores, inter_model)");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.models         = models;         % r
  this.cluster_scores = cluster_scores; % r * (k_r * 1)
  this.inter_model    = inter_model;

  %% Bless
  %% And add inheritance
  this = class(this, "EWOCSModel", ...
               Simple());
endfunction
