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
%% @deftypefn {Function File} {[ @var{F} ] =} spfactorial(@var{N})
%% Sparse version of factorial(N) (0! = 0)
%% @end deftypefn

function [ F ] = spfactorial(N)

  %% Args
  if nargin() ~= 1
    usage("[ F ] = spfactorial(N)");
  endif

  %% Sparse?
  if issparse(N)
    %% Get size and nonzero entries
    [ r,  c      ] = size(N);
    [ ri, ci, nz ] = find(N);

    %% Construct a matrix with the factorial
    F = sparse(ri, ci, factorial(nz), r, c);

  else
    %% Regular one
    F = factorial(N);
  endif
endfunction

%% Local Variables:
%% mode:octave
%% End:
