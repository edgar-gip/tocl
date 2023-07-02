// Copyright (C) 2010 Edgar Gonzàlez i Pellicer <edgar.gip@gmail.com>
//
// This file is part of octopus-0.1.
//
// octopus is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the
// Free Software Foundation; either version 3 of the License, or (at your
// option) any later version.
//
// octopus is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for more details.
//
// You should have received a copy of the GNU General Public License
// along with octopus; see the file COPYING.  If not, see
// <http://www.gnu.org/licenses/>.

#ifndef QUADPROG_COMMON
#define QUADPROG_COMMON

#include <octave/oct.h>
#include <octave/oct-map.h>

// Parse quadprog arguments
void parse_quadprog_args(const octave_value_list& args,
                         int& n_vars, int& n_ineq, int& n_eq,
                         Matrix& H, ColumnVector& f,
                         Matrix& Aineq, ColumnVector& bineq,
                         Matrix& Aeq, ColumnVector& beq,
                         ColumnVector& lb, ColumnVector& ub,
                         ColumnVector& x, Octave_map& opts) throw (const char*);

#endif
