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

%% Test for get_options.m

%% Load the package
pkg load octopus;

%% Test and show the results
[ args, opts ] = get_options("simple",     "simple", ...
                             "negable!",   "negable", ...
                             "pseudo~",    "simple", ...
                             "negated-",   "simple", ...
                             "integer=i",  "integer", ...
                             "float=f",    "float", ...
                             "string=s",   "string", ...
                             "radio1=r1", "radio", ...
                             "radio2=r2", "radio", ...
                             "radio3=r3", "radio", ...
                             "radio4=r4", "radio")

%% Local Variables:
%% mode:octave
%% End:
