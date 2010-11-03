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
%% @deftypefn {Function File} {[ @var{x}, @var{fval}, @var{info} ] =} quadprog(@var{H}, @var{f}, @var{Aineq}, @var{bineq}, @var{Aeq}, @var{beq}, @var{lb}, @var{ub}, @var{x0}, @var{options})
%% Solve quadratic problems
%% @end deftypefn

function [ x, fval, info ] = quadprog(varargin)

  %% Get the requested backend
  n_argin = length(varargin);
  if n_argin < 10
    backend = "turlach";
  else
    options = varargin{10};

    if ~isstruct(options)
      usage("opts should be a struct");
    elseif ~isfield(options, "backend")
      backend = "turlach";
    elseif ~ischar((backend = options.backend))
      usage("opts.backend should be a string");
    endif
  endif

  %% Forward the call to the corresponding function
  if     strcmp(backend, "cgal")
    quadprog_cgal(varargin{:});
  elseif strcmp(backend, "turlach")
    quadprog_turlach(varargin{:});
  else
    usage(sprintf("backend %s not implemented", backend));
  endif
endfunction

%% Local Variables:
%% mode:octave
%% End:
