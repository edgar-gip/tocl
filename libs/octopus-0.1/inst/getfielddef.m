%% Copyright (C) 2010 Edgar Gonzàlez i Pellicer <edgar.gip@gmail.com>
%%
%% This file is part of octopus-0.1.
%%
%% octopus is free software; you can redistribute it and/or modify it
%% under the terms of the GNU General Public License as published by the
%% Free Software Foundation; either version 3 of the License, or (at your
%% option) any later version.
%%
%% octopus is distributed in the hope that it will be useful, but WITHOUT
%% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
%% FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
%% for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with octopus; see the file COPYING.  If not, see
%% <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @deftypefn {Function File} {[ @var{value} ] =} getfielddef(@var{s}, @var{key}, @var{defvalue})
%% Extract a field from a structure, giving a default value if it does not exist
%% @end deftypefn

function [ value ] = getfielddef(s, key, defvalue)

  %% Args
  if nargin() ~= 3
    usage("[ value ] = getfielddef(s, key, defvalue)");
  endif

  %% Is it a structure with the required field
  if isstruct(s) && isfield(s, key)
    value = getfield(s, key);
  else
    value = defvalue;
  endif
endfunction

%% Local Variables:
%% mode:octave
%% End:
