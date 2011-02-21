%% -*- mode: octave; -*-

%% 1-D Gaussian distribution clustering
%% Sort cluster by means

%% Author: Edgar Gonzalez

function [ new_model, sorted_cl ] = sort_means(this, mode = "ascend");

  %% Check arguments
  if ~any(nargin() == [ 1, 2 ])
    usage("[ m ] = @Gaussian1DModel/sort_means(this [, mode])");
  endif

  %% Sort the means
  [ sorted_mean, sorted_cl ] = sort(this.mean, mode);

  %% Sort the other vars
  sorted_alpha = this.alpha(sorted_cl);
  sorted_var   = this.var(sorted_cl);

  %% Create the new model
  new_model = Gaussian1DModel(this.k, sorted_alpha, sorted_mean, sorted_var);
endfunction
