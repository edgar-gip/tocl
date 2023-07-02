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

#include <exception>

#include <octave/oct.h>
#include <octave/ov-fcn.h>
#include <octave/parse.h>


/*******************************/
/* Zip arrays using a function */
/*******************************/

DEFUN_DLD(array_zip, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[ @var{matrix} ] =}\
 array_zip(@var{f}, @var{x1}, [@var{x2}, ...]])\n\
\n\
Zip arrays using a function\n\
@end deftypefn") {
  // Result
  octave_value_list result;

  try {
    // Check the number of parameters
    if (args.length() < 2 or nargout > 1)
      throw (const char*)0;

    // @todo Unimplemented yet
    throw "Unimplemented";
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


/*****************************************/
/* Cross-zip two arrays using a function */
/*****************************************/

// PKG_ADD: autoload('array_cross_zip', which('array_zip'));

DEFUN_DLD(array_cross_zip, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[ @var{matrix} ] =}\
 array_cross_zip(@var{f}, @var{x}, @var{y))\n\
\n\
Cross zip two arrays @var{x} and @var{y} using function @var{f}\n\
@end deftypefn") {
  // Result
  octave_value_list result;

  try {
    // Check the number of parameters
    if (args.length() != 3 or nargout > 1)
      throw (const char*)0;

    // Check first argument
    if (not args(0).is_function_handle())
      throw "f should be a function handle";
    octave_function* f = args(0).function_value();

    // Check second argument
    if (not args(1).is_real_matrix())
      throw "x should be a real matrix";
    Matrix x = args(1).matrix_value();

    // Check third argument
    if (not args(2).is_real_matrix())
      throw "y should be a real matrix";
    Matrix y = args(2).matrix_value();

    // Output
    Matrix out(x.length(), y.length());

    // Evaluate each value
    octave_value_list args;
    args.resize(2);
    for (int r = 0; r < x.length(); ++r) {
      // x
      args(0) = x(r);

      for (int c = 0; c < y.length(); ++c) {
        // y
        args(1) = y(c);

        // Result
        octave_value_list res = feval(f, args, 1);
        if (res.length() < 1 or not res(0).is_real_scalar())
          out(r, c) = NAN;
        else
          out(r, c) = res(0).scalar_value();
      }
    }

    // Set
    result.resize(1);
    result(0) = out;
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
