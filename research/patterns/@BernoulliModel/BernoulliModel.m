%% -*- mode: octave; -*-

%% Bernoulli distribution clustering
%% Model constructor

%% Author: Edgar Gonzalez

function [ this ] = BernoulliModel(k, alpha, alpha_ctheta, theta)

  %% Check arguments
  if nargin() ~= 4
    usage("[ this ] = BernoulliModel(k, alpha, alpha_ctheta, theta)");
  endif

  %% This object
  this = struct();

  %% Set fields
  this.k            = k;
  this.alpha        = alpha;        % k * 1
  this.alpha_ctheta = alpha_ctheta; % k * 1
  this.theta        = theta;        % k * n_dims

  %% Bless
  %% And add inheritance
  this = class(this, "BernoulliModel", ...
               Simple());
endfunction
