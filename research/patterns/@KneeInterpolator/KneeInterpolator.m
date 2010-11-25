%% -*- mode: octave; -*-

%% Knee-detection interpolator
%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = KneeInterpolator(finder = DistanceKnee(), ...
				     inner = @LogInterpolator, ...
				     low = 0.0, mid = 0.5, high = 1.0)

  %% Check arguments
  if ~any(nargin() == [ 1, 2, 5 ])
    usage("[ this ] = KneeInterpolator([finder, [inner [, low, mid, high]]])");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.finder     = finder;
  this.low        = low;
  this.mid        = mid;
  this.high       = high;
  this.low_inter  = feval(inner, low, mid);
  this.high_inter = feval(inner, mid, high);

  %% Bless
  %% And add inheritance
  this = class(this, "KneeInterpolator", ...
	       Simple());
endfunction
