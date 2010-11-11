%% -*- mode: octave; -*-

%% Cluster interpolator
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = ClusterInterpolator(clusterer = Gaussian1D(),
					opts = struct())

  %% Check arguments
  if ~any(nargin() == [ 0, 1 ])
    usage("[ this ] = ClusterInterpolator([clusterer [, opts]])");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.clusterer = clusterer;
  this.total_k   = getfielddef(opts, "total_k", 2);
  this.low_k     = getfielddef(opts, "low_k",   1);

  %% Bless
  %% And add inheritance
  this = class(this, "ClusterInterpolator", ...
	       Simple());
endfunction
