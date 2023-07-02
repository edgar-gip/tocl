%% -*- mode: octave; -*-

%% Data size

%% Author: Edgar Gonzàlez i Pellicer

function [ n_data ] = data_size(data)

  %% Is it a cell?
  if iscell(data)
    %% Return the size of the first one
    [ n_dims, n_data ] = size(data{1});

  else
    %% Direct size
    [ n_dims, n_data ] = size(data);
  endif
endfunction
