// Copyright (C) 2010 Edgar Gonzàlez i Pellicer <edgar.gip@gmail.com>
//
// This file is part of liboctave-0.1.
//
// liboctave is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the
// Free Software Foundation; either version 3 of the License, or (at your
// option) any later version.
//
// liboctave is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for more details.
// 
// You should have received a copy of the GNU General Public License
// along with liboctave; see the file COPYING.  If not, see
// <http://www.gnu.org/licenses/>.


#include <exception>

#include <octave/oct.h>


/****************/
/* Append cells */
/****************/

DEFUN_DLD(cell_cat, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[ @var{cell} ] =} cell_cat(@var{cell}, ...)\n\
\n\
Append cells\n\
@end deftypefn") {
  // Result
  octave_value_list result;

  try {
    // Check the number of parameters
    if (nargout != 1)
      throw (const char*)0;
	
    // Result
    Cell cat;

    // For each argument
    for (int i = 0; i < args.length(); ++i) {
      // Is it a cell?
      if (not args(i).is_cell())
	throw "Arguments should be cells";

      // Add each element
      Cell current = args(i).cell_value();
      for (int j = 0; j < current.length(); ++j) {
	cat.resize(cat.length() + 1);
	cat(cat.length() - 1) = current(j);
      }
    }

    // Set
    result.resize(nargout);
    result(0) = cat;
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


/******************/
/* Push to a cell */
/******************/

DEFUN_DLD(cell_push, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[ @var{cell} ] =} cell_push(@var{cell}, ...)\n\
\n\
Push to a cell\n\
@end deftypefn") {
  // Result
  octave_value_list result;

  try {
    // Check the number of parameters
    if (args.length() < 1 or nargout != 1)
      throw (const char*)0;
	
    // Value
    if (not args(0).is_cell())
      throw "First argument should be a cell";
    Cell cat = args(0).cell_value();

    // For each argument
    for (int i = 1; i < args.length(); ++i) {
      cat.resize(cat.length() + 1);
      cat(cat.length() - 1) = args(i);
    }

    // Set
    result.resize(nargout);
    result(0) = cat;
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


/******************/
/* Tail of a cell */
/******************/

DEFUN_DLD(cell_tail, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[ @var{cell} ] =} cell_tail(@var{cell})\n\
\n\
Tail of a cell\n\
@end deftypefn") {
  // Result
  octave_value_list result;

  try {
    // Check the number of parameters
    if (args.length() != 1 or nargout != 1)
      throw (const char*)0;
	
    // Value
    if (not args(0).is_cell())
      throw "First argument should be a cell";
    Cell c = args(0).cell_value();

    // Empty?
    if (c.is_empty())
      throw "Empty cell";

    // Remove the first one
    for (int i = 1; i < c.length(); ++i)
      c(i - 1) = c(i);
    c.resize(c.length() - 1);

    // Result
    result.resize(nargout);
    result(0) = c;
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
