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
%% @deftypefn {Function File} {[ @var{values} ] =} log_series(@var{from}, @var{to}, @var{steps})
%% Generate a log-stepped series between @var{from} and @var{to}
%% @end deftypefn

%% Log-series
function [ values ] = log_series(from, to, steps)
  %% Bounds
  log_from = log(from);
  log_to   = log(to);

  %% Step
  step = (log_to - log_from) / (steps - 1);

  %% Values
  values = exp(log_from + step * ((1 : steps) - 1));
endfunction

%% Local Variables:
%% mode:octave
%% End:
