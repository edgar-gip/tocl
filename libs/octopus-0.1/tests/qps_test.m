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

%% Test for parse_qps.m, quadprog.m

%% Load the package
pkg load octopus;

%% Arguments
file = argv(){1};
fval = str2num(argv(){2});

%% Display
printf("%40s  Actual: %15g", file, fval);

%% Parse the file
[ H, f, g, Aineq, bineq, Aeq, beq, lb, ub ] = parse_qps(file);

%% Solve by CGAL
[ x1_cgal, obj_cgal ] = quadprog_cgal(H, f, Aineq, bineq, Aeq, beq, lb, ub);
obj_cgal += g;

%% Display
printf("  CGAL: %15g", obj_cgal);

%% Solve by Turlach
[ x1_tur, obj_tur ] = quadprog_turlach(H, f, Aineq, bineq, Aeq, beq, lb, ub);
obj_tur += g;

%% Display
printf("  Turlach: %15g", obj_tur);

%% Local Variables:
%% mode:octave
%% End:
