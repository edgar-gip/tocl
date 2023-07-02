%% -*- mode: octave; -*-

%% Dirichlet distribution clustering
%% Model constructor

%% Author: Edgar Gonzalez

function [ this ] = DirichletModel(k, blocks, alpha, log_z, alpha_z, theta_m1)

  %% Check arguments
  if nargin() ~= 6
    usage(cstrcat("[ this ] = DirichletModel(k, blocks, alpha, log_z,",
                  " alpha_z, theta_m1)"));
  endif

  %% This object
  this = struct();

  %% Set fields
  this.k        = k;
  this.blocks   = blocks;
  this.alpha    = alpha;    % k * 1
  this.log_z    = log_z;    % k * n_blocks
  this.alpha_z  = alpha_z;  % k * 1
  this.theta_m1 = theta_m1; % k * n_dims

  %% Bless
  %% And add inheritance
  this = class(this, "DirichletModel", ...
               Simple());
endfunction
