%% -*- mode: octave; -*-

%% Convert a file name relative to the binary location

%% Author: Edgar Gonzàlez i Pellicer

function [ absolute ] = binrel(relative)
  %% Binary path
  bin_path = program_invocation_name();

  %% Split
  [ bin_dir, bin_name, bin_ext, bin_ver ] = fileparts(bin_path);

  %% Convert to absolute
  absolute = fullfile(bin_dir, relative);
endfunction
