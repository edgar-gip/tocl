%% -*- mode: octave; -*-

%% Random clustering
%% Expectation

%% Author: Edgar Gonzalez

function [ expec, log_like ] = expectation(this, data)

  %% Check arguments
  if nargin() ~= 2
    usage("[ expec, log_like ] = @RandomModel/expectation(this, data)");
  endif

  %% Apply the projection matrix
  margin = this.projection * data;

  %% Hard or soft?
  if isfinite(this.soft_alpha)
    %% Soft
    expec = distance_probability(this.soft_alpha, margin);
  else
    %% Hard
    expec = distance_winner(margin);
  endif

  %% Log-like is not considered here
  log_like = nan;
endfunction
