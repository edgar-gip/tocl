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

%% Test for quadprog.m

%% Load the package
pkg load octopus;

%% Example from MATLAB documentation
H  = [ 1 -1; -1 2 ];
f  = [ -2; -6 ];
A  = [ 1 1; -1 2; 2 1 ];
b  = [ 2; 2; 3 ];
lb = zeros(2, 1);
[ x, fval ] = quadprog_cgal   (H, f, A, b, [], [], lb)
[ x, fval ] = quadprog_turlach(H, f, A, b, [], [], lb)
%% x = [ 0.6667 ; 1.3333 ]
%% fval = -8.2222

%% Example from CGAL documentation
D  = [ 2 0 ; 0 8 ];
C  = [ 0 ; -32 ];
%% c0 = 64;
A  = [ 1, 1 ; -1,  2 ];
B  = [ 7 ; 4 ];
lb = zeros(2, 1);
ub = [ inf ; 4 ];
[ x, fval ] = quadprog_cgal   (D, C, A, B, [], [], lb, ub)
[ x, fval ] = quadprog_turlach(D, C, A, B, [], [], lb, ub)
%% x = [ 2 ; 3 ]
%% fval = 8 (-64 = -56)

%% Example from CGAL documentation
D  = zeros(2, 2);
C  = [ 0 ; -32 ];
%% c0 = 64
A  = [ 1, 1 ; -1, 2 ];
B  = [ 7 ; 4 ];
lb = zeros(2, 1);
ub = [ inf ; 4 ];
[ x, fval ] = quadprog_cgal   (D, C, A, B, [], [], lb, ub)
%% [ x, fval ] = quadprog_turlach(D, C, A, B, [], [], lb, ub)
%% x = [ 3.3333 ; 3.6667 ]
%% fval = -53.333 (-64 = -117.33)

%% Local Variables:
%% mode:octave
%% End:
