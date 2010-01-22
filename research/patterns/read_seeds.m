%% -*- mode: octave; -*-

%% Read seeds from a file

%% Author: Edgar Gonzàlez i Pellicer

function [ seeds ] = read_seeds(file)
  %% Open the file
  f = istream_open(file);

  %% Empty matrix
  seeds = [];

  %% Read each line
  while ischar(line = istream_readline(f))
    %% Match?
    if (([ match, run, seed1, seed2 ] =
	 regex_match(line, '# Run: #(\d+) Seeds: (\d+), (\d+)')))
      %% Save
      seeds = [ seeds ; str2num(run), str2num(seed1), str2num(seed2) ];
    endif
  endwhile
endfunction
