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

#include "quadprog_common.h"

#ifdef HAVE_CONFIG_H
#include "undefs.h"
#include "config.h"
#endif

// Parse quadprog arguments
void parse_quadprog_args(const octave_value_list& args,
                         int& n_vars, int& n_ineq, int& n_eq,
                         Matrix& H, ColumnVector& f,
                         Matrix& Aineq, ColumnVector& bineq,
                         Matrix& Aeq, ColumnVector& beq,
                         ColumnVector& lb, ColumnVector& ub,
                         ColumnVector& x, Octave_map& opts) throw (const char*) {
  // Check the number of parameters
  if (args.length() < 4 or args.length() > 10)
    throw (const char*)0;

  // Get H
  if (args(0).is_real_scalar()) {
    H.RESIZE_AND_FILL(1, 1, args(0).scalar_value());
    n_vars = 1;
  }
  else if (args(0).is_real_matrix()) {
    if (args(0).rows() != args(0).columns())
      throw "H should be a square matrix";
    H = args(0).matrix_value();
    n_vars = H.rows();
  }
  else {
    throw "H should be a square matrix";
  }

  // Get f
  if (args(1).is_real_scalar()) {
    if (n_vars != 1)
      throw "f should be a column vector with the same rows as H";
#ifdef RESIZE_VECTOR_ONE_ARG
    f.RESIZE_AND_FILL(1, args(1).scalar_value());
#else
    f.RESIZE_AND_FILL(1, 1, args(1).scalar_value());
#endif
  }
  else if (args(1).is_real_matrix()) {
    if (args(1).columns() != 1 or args(1).rows() != n_vars)
      throw "f should be a column vector with the same rows as H";
    f = args(1).column_vector_value();
  }
  else {
    throw "f should be a column vector with the same rows as H";
  }

  // Get Aineq
  if (args(2).is_zero_by_zero()) {
    n_ineq = 0;
  }
  else if (args(2).is_real_scalar()) {
    if (n_vars != 1)
      throw "Aineq should be a matrix with the same columns as H";
    Aineq.RESIZE_AND_FILL(1, 1, args(2).scalar_value());
    n_ineq = 1;
  }
  else if (args(2).is_real_matrix()) {
    if (args(2).columns() != n_vars)
      throw "Aineq should be a matrix with the same columns as H";
    Aineq = args(2).matrix_value();
    n_ineq = Aineq.rows();
  }
  else {
    throw "Aineq should be a matrix with the same columns as H";
  }

  // Get bineq
  if (args(3).is_zero_by_zero()) {
    if (n_ineq != 0)
      throw "bineq should be a column vector with the same rows as Aineq";
  }
  else if (args(3).is_real_scalar()) {
    if (n_ineq != 1)
      throw "bineq should be a column vector with the same rows as Aineq";
#ifdef RESIZE_VECTOR_ONE_ARG
    bineq.RESIZE_AND_FILL(1, args(3).scalar_value());
#else
    bineq.RESIZE_AND_FILL(1, 1, args(3).scalar_value());
#endif
  }
  else if (args(3).is_real_matrix()) {
    if (args(3).columns() != 1 or args(3).rows() != n_ineq)
      throw "bineq should be a column vector with the same rows as Aineq";
    bineq = args(3).column_vector_value();
  }
  else {
    throw "bineq should be a column vector with the same rows as Aineq";
  }

  // Equality

  // Get Aeq
  if (args.length() <= 4 or args(4).is_zero_by_zero()) {
    n_eq = 0;
  }
  else if (args(4).is_real_scalar()) {
    if (n_vars != 1)
      throw "Aeq should be a matrix with the same columns as H";
    Aeq.RESIZE_AND_FILL(1, 1, args(4).scalar_value());
    n_eq = 1;
  }
  else if (args(4).is_real_matrix()) {
    if (args(4).columns() != n_vars)
      throw "Aeq should be a matrix with the same columns as H";
    Aeq = args(4).matrix_value();
    n_eq = Aeq.rows();
  }
  else {
    throw "Aeq should be a matrix with the same columns as H";
  }

  // Get beq
  if (args.length() <= 5 or args(5).is_zero_by_zero()) {
    if (n_eq != 0)
      throw "beq should be a column vector with the same rows as Aeq";
  }
  else if (args(5).is_real_scalar()) {
    if (n_eq != 1)
      throw "beq should be a column vector with the same rows as Aeq";
#ifdef RESIZE_VECTOR_ONE_ARG
    beq.RESIZE_AND_FILL(1, args(5).scalar_value());
#else
    beq.RESIZE_AND_FILL(1, 1, args(5).scalar_value());
#endif
  }
  else if (args(5).is_real_matrix()) {
    if (args(5).columns() != 1 or args(5).rows() != n_eq)
      throw "beq should be a column vector with the same rows as Aeq";
    beq = args(5).column_vector_value();
  }
  else {
    throw "beq should be a column vector with the same rows as Aeq";
  }

  // Bounds

  // Get lb
  if (args.length() <= 6 or args(6).is_zero_by_zero()) {
#ifdef RESIZE_VECTOR_ONE_ARG
    lb.RESIZE_AND_FILL(n_vars, -INFINITY);
#else
    lb.RESIZE_AND_FILL(n_vars, 1, -INFINITY);
#endif
  }
  else if (args(6).is_real_scalar()) {
    if (n_vars != 1)
      throw "lb should be a column vector with the same rows as H";
#ifdef RESIZE_VECTOR_ONE_ARG
    lb.RESIZE_AND_FILL(n_vars, args(6).scalar_value());
#else
    lb.RESIZE_AND_FILL(n_vars, 1, args(6).scalar_value());
#endif
  }
  else if (args(6).is_real_matrix()) {
    if (args(6).columns() != 1 or args(6).rows() != n_vars)
      throw "lb should be a column vector with the same rows as H";
    lb = args(6).column_vector_value();
  }
  else {
    throw "lb should be a column vector with the same rows as H";
  }

  // Get ub
  if (args.length() <= 7 or args(7).is_zero_by_zero()) {
#ifdef RESIZE_VECTOR_ONE_ARG
    ub.RESIZE_AND_FILL(n_vars, INFINITY);
#else
    ub.RESIZE_AND_FILL(n_vars, 1, INFINITY);
#endif
  }
  else if (args(7).is_real_scalar()) {
    if (n_vars != 1)
      throw "ub should be a column vector with the same rows as H";
#ifdef RESIZE_VECTOR_ONE_ARG
    ub.RESIZE_AND_FILL(n_vars, args(7).scalar_value());
#else
    ub.RESIZE_AND_FILL(n_vars, 1, args(7).scalar_value());
#endif
  }
  else if (args(7).is_real_matrix()) {
    if (args(7).columns() != 1 or args(7).rows() != n_vars)
      throw "ub should be a column vector with the same rows as H";
    ub = args(7).column_vector_value();
  }
  else {
    throw "ub should be a column vector with the same rows as H";
  }

  // Starting value

  // Get x0
  if (args.length() <= 8 or args(8).is_zero_by_zero()) {
#ifdef RESIZE_VECTOR_ONE_ARG
    x.RESIZE_AND_FILL(n_vars, 0.0);
#else
    x.RESIZE_AND_FILL(n_vars, 1, 0.0);
#endif
  }
  else if (args(8).is_real_scalar()) {
    if (n_vars != 1)
      throw "x0 should be a column vector with the same rows as H";
#ifdef RESIZE_VECTOR_ONE_ARG
    x.RESIZE_AND_FILL(n_vars, args(8).scalar_value());
#else
    x.RESIZE_AND_FILL(n_vars, 1, args(8).scalar_value());
#endif
  }
  else if (args(8).is_real_matrix()) {
    if (args(8).columns() != 1 or args(8).rows() != n_vars)
      throw "x0 should be a column vector with the same rows as H";
    x = args(8).column_vector_value();
  }
  else {
    throw "x0 should be a column vector with the same rows as H";
  }

  // Options
  if (args.length() > 9) {
    if (args(9).is_map())
      opts = args(9).map_value();
    else
      throw "opts should be a struct";
  }
}
