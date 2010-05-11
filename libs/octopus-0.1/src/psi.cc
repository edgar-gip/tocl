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

#include <cmath>
#include <exception>

#include <octave/oct.h>

#define MATHLIB_STANDALONE
#include <Rmath.h>


/********************/
/* Helper functions */
/********************/

// Inverse psi function
/* Solved by the Newton-Raphson Method
 */
static double psigamma_inv(double y, double deriv) {
  // Threshold
  const int    ITERATIONS = 1000;
  const double THRESHOLD  = 1e-12;

  // Starting solution
  double x = 1.0;
  double f = psigamma(x, deriv) - y;

  // Loop
  for (int i = 0; i < ITERATIONS; ++i) {
    // Update
    /* x = x - f(x) / f'(x)
     */
    x -= f / psigamma(x, deriv + 1.0);

    // New function value
    f = psigamma(x, deriv) - y;
    
    // Exit if the function is close enough to zero
    if (std::abs(f) < THRESHOLD)
      return x;
  }
  
  // Not found!
  return NAN;
}


/*******************************/
/* Psi (or Polygamma) function */
/*******************************/

DEFUN_DLD(psi, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[ @var{Y} ] =}\
 psi([ @var{k}, ] @var{X})\n\
\n\
Compute the psi (or polygamma) function for each element\n\
of array @var{X}\n\
@end deftypefn") {
  // Result
  octave_value_list result;

  try {
    // Check the number of parameters
    if (args.length() < 1 or args.length() > 2 or nargout > 1)
      throw (const char*)0;

    // Arguments
    bool is_k_scalar;
    Matrix k;
    bool is_x_scalar;
    Matrix x;

    // Resulting columns and rows
    int rows;
    int cols;

    // One or two arguments?
    if (args.length() == 1) {
      // K is the scalar 0
      is_k_scalar = true;
      k = Matrix(1, 1, 0.0);

      // Get the argument
      if (args(0).is_real_scalar()) {
	is_x_scalar = true;
      }
      else if (args(0).is_real_matrix()) {
	is_x_scalar = false;
      }
      else {
	throw "x should be a real scalar or matrix";
      }
      x = args(0).matrix_value();

      // Resulting rows and columns
      rows = x.rows();
      cols = x.columns();
    }
    else {
      // Get the first argument
      if (args(0).is_real_scalar()) {
	is_k_scalar = true;
      }
      else if (args(0).is_real_matrix()) {
	is_k_scalar = false;
      }
      else {
	throw "k should be a real scalar or matrix";
      }
      k = args(0).matrix_value();

      // Resulting rows and columns
      rows = k.rows();
      cols = k.columns();

      // Get the second argument
      if (args(1).is_real_scalar()) {
	is_x_scalar = true;
      }
      else if (args(1).is_real_matrix()) {
	is_x_scalar = false;
      }
      else {
	throw "x should be a real scalar or matrix";
      }
      x = args(1).matrix_value();
      
      // Check dimensions
      if (not is_x_scalar) {
	if (is_k_scalar) {
	  rows = x.rows();
	  cols = x.columns();
	}
	else if (x.rows() != rows or x.columns() != cols) {
	  throw "k and x should have the same size";
	}
      }
    }

    // All two scalars?
    if (is_k_scalar and is_x_scalar) {
      // Return a single scalar
      result(0) = psigamma(x(0, 0), k(0, 0));
    }
    else {
      // Return a whole matrix
      Matrix out(rows, cols);

      // Loop
      for (int r = 0; r < rows; ++r) {
	for (int c = 0; c < cols; ++c) {
	  double kv = is_k_scalar ? k(0, 0) : k(r, c);
	  double xv = is_x_scalar ? x(0, 0) : x(r, c);
	  out(r, c) = psigamma(xv, kv);
	}
      }

      // Set it
      result(0) = out;
    }
  }
  // Was there an error?
  catch (const char* _error) {
    // Display the error or the usage
    if (_error)
      error(_error);
    else
      print_usage();
  }
  // Was there an exception
  catch (std::exception& _excep) {
    // Display the error
    error(_excep.what());
  }

  // Return the result
  return result;
}


/***************************************/
/* Inverse Psi (or Polygamma) function */
/***************************************/

// PKG_ADD: autoload('psi_inv', which('psi'));

DEFUN_DLD(psi_inv, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[ @var{Y} ] =}\
 psi_inv([ @var{k}, ] @var{X})\n\
\n\
Compute the inverse psi (or polygamma) function for each element\n\
of array @var{X}\n\
@end deftypefn") {
  // Result
  octave_value_list result;

  try {
    // Check the number of parameters
    if (args.length() < 1 or args.length() > 2 or nargout > 1)
      throw (const char*)0;

    // Arguments
    bool is_k_scalar;
    Matrix k;
    bool is_x_scalar;
    Matrix x;

    // Resulting columns and rows
    int rows;
    int cols;

    // One or two arguments?
    if (args.length() == 1) {
      // K is the scalar 0
      is_k_scalar = true;
      k = Matrix(1, 1, 0.0);

      // Get the argument
      if (args(0).is_real_scalar()) {
	is_x_scalar = true;
      }
      else if (args(0).is_real_matrix()) {
	is_x_scalar = false;
      }
      else {
	throw "x should be a real scalar or matrix";
      }
      x = args(0).matrix_value();

      // Resulting rows and columns
      rows = x.rows();
      cols = x.columns();
    }
    else {
      // Get the first argument
      if (args(0).is_real_scalar()) {
	is_k_scalar = true;
      }
      else if (args(0).is_real_matrix()) {
	is_k_scalar = false;
      }
      else {
	throw "k should be a real scalar or matrix";
      }
      k = args(0).matrix_value();

      // Resulting rows and columns
      rows = k.rows();
      cols = k.columns();

      // Get the second argument
      if (args(1).is_real_scalar()) {
	is_x_scalar = true;
      }
      else if (args(1).is_real_matrix()) {
	is_x_scalar = false;
      }
      else {
	throw "x should be a real scalar or matrix";
      }
      x = args(1).matrix_value();
      
      // Check dimensions
      if (not is_x_scalar) {
	if (is_k_scalar) {
	  rows = x.rows();
	  cols = x.columns();
	}
	else if (x.rows() != rows or x.columns() != cols) {
	  throw "k and x should have the same size";
	}
      }
    }

    // All two scalars?
    if (is_k_scalar and is_x_scalar) {
      // Return a single scalar
      result(0) = psigamma_inv(x(0, 0), k(0, 0));
    }
    else {
      // Return a whole matrix
      Matrix out(rows, cols);

      // Loop
      for (int r = 0; r < rows; ++r) {
	for (int c = 0; c < cols; ++c) {
	  double kv = is_k_scalar ? k(0, 0) : k(r, c);
	  double xv = is_x_scalar ? x(0, 0) : x(r, c);
	  out(r, c) = psigamma_inv(xv, kv);
	}
      }

      // Set it
      result(0) = out;
    }
  }
  // Was there an error?
  catch (const char* _error) {
    // Display the error or the usage
    if (_error)
      error(_error);
    else
      print_usage();
  }
  // Was there an exception
  catch (std::exception& _excep) {
    // Display the error
    error(_excep.what());
  }

  // Return the result
  return result;
}
