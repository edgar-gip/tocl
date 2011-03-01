%% Copyright (C) 2011 Edgar Gonzàlez i Pellicer <edgar.gip@gmail.com>
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
%% @deftypefn {Function File} {[ @var{value} ] =} parse_double(@var{string}, @var{label})
%% Convenience function to parse a double value and notify errors
%% @end deftypefn

%% Parse a double
function [ value ] = parse_double(string, label = "value")
  [ value, status ] = str2double(string);
  if status ~= 0
    error("Wrong %s '%s'", label, string)
  endif
endfunction

%% Local Variables:
%% mode:octave
%% End:
