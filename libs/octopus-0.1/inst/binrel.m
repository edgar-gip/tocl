%% -*- mode: octave; -*-

%% Convert a file name relative to the binary location

%% Author: Edgar Gonzàlez i Pellicer

function [ absolute ] = binrel(relative)

  %% Binary path
  bin_path = program_invocation_name();

  %% Split
  [ bin_dir, bin_name, bin_ext, bin_ver ] = fileparts(bin_path);

  %% Convert to absolute
  if nargin() > 0
    absolute = fullfile(bin_dir, relative);
  elseif isempty(bin_dir)
    absolute = ".";
  else
    absolute = bin_dir;
  endif
endfunction
