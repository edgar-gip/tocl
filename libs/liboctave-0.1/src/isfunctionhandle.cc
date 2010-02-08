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


#include <octave/oct.h>


/************************************/
/* Is the object a function handle? */
/************************************/

DEFUN_DLD(isfunctionhandle, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[ @var{is}, ] =}\
 isfunctionhandle(@var{object})\n\
\n\
Is the @var{object} a function handle?\n\
@end deftypefn") {
  // Result
  octave_value_list result;

  // Check the number of parameters
  if (args.length() != 1 or nargout != 1) {
    // Print the usage
    print_usage();
  }
  else {
    // Result
    result.resize(nargout);
    result(0) = args(0).is_function_handle();
  }

  // Return result
  return result;
}
