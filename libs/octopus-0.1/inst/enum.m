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
%% @deftypefn {Command} enum @var{value} @var{value} ...
%% Define enumerations
%% @end deftypefn

function enum(varargin)

  %% Last enum value
  last = -1;

  %% For each argument
  for i = 1 : length(varargin)

    %% Check it is a valid string
    if ~ischar(varargin{i})
      %% Error!
      usage("Enumeration value names must be strings");

    elseif regex_match(varargin{i}, '[a-zA-Z]\w*')
      %% Define the function to be equal to the next value
      ++last;
      eval(sprintf("function v = %s(); v = %d; end;", varargin{i}, last));

    elseif (([ match, name, value ] = ...
	     regex_match(varargin{i}, '([a-zA-Z]\w*)=([\+\-]?\d+)')))
      %% Define the function to be equal to the specified value
      last = fix(str2double(value));
      eval(sprintf("function v = %s(); v = %d; end;", name, last));

    else
      %% Error!
      usage("Wrong enumeration value specification %s", varargin{i});
    endif
  endfor
endfunction

%% Mark as command
%% mark_as_command("enum");

%% Local Variables:
%% mode:octave
%% End:
