%% -*- mode: octave; -*-

%% Cutting Plane Maximum Margin Clustering Algorithm (CPMMC)
%% Find the most violated constraint

%% Author: Edgar Gonzalez

%% Based in CPMMC.m
%% Author: Bin Zhao

function [ constraint, violation ] = CPMMC_mvc(data, omega, b);

  %% Sizes
  [ n_dims, n_data ] = size(data);

  %% Product
  prod = abs(omega' * data + b)'; % n_data * 1

  %% Find the most violated constraint in the original problem
  constraint = prod < 1;
  violation  = sum((1 - prod)(constraint)) / n_data;
endfunction
