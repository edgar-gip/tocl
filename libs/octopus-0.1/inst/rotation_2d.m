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
%% @deftypefn {Function File} {[ @var{r} ] =} rotation_2d(@var{angle})
%% Generate the 2D rotation matrix with angle @var{angle}
%% @end deftypefn

%% Rotation matrix
function [ R ] = rotation_2d(angle)

  %% Find the trigonometric values
  c = cos(angle);
  s = sin(angle);

  %% Just create the matrix
  R = [ c, -s ; s, c ];
endfunction

%% Local Variables:
%% mode:octave
%% End:
