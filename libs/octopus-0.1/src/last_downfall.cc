// Copyright (C) 2011 Edgar Gonzàlez i Pellicer <edgar.gip@gmail.com>
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


/**********************/
/* Direction Policies */
/**********************/

// First (Left-to-Right)
struct First {
  // Start
  static octave_idx_type start(octave_idx_type /* _length */) {
    return 0;
  }

  // End condition
  static bool more(octave_idx_type _i, octave_idx_type _length) {
    return _i < _length - 1;
  }

  // Next
  static void next(octave_idx_type& _i) {
    ++_i;
  }
};

// Last (Right-to-Left)
struct Last {
  // Start
  static octave_idx_type start(octave_idx_type _length) {
    return _length - 2;
  }

  // End condition
  static bool more(octave_idx_type _i, octave_idx_type /* _length */) {
    return _i >= 0;
  }

  // Next
  static void next(octave_idx_type& _i) {
    --_i;
  }
};


/*****************/
/* Fall policies */
/*****************/

// Downfall
struct Downfall {
  // Active
  static bool active(double _left, double _right, double _threshold) {
    return _left >= _threshold and _right < _threshold;
  }
};

// Uprise
struct Uprise {
  // Active
  static bool active(double _left, double _right, double _threshold) {
    return _left < _threshold and _right >= _threshold;
  }
};


/**********/
/* Finder */
/**********/

// Find it
template <typename DirP, typename FallP>
static octave_value_list
find_it(const octave_value_list& _args, int _nargout) {
  // Result
  octave_value_list result;

  try {
    // Check the number of parameters
    if ((_args.length() != 1 and _args.length() != 2) or _nargout > 1)
      throw (const char*)0;

    // Threshold
    double threshold = 0.0; /* Default value */
    if (_args.length() >= 2) {
      // Check it is a scalar
      if (not _args(1).is_scalar_type() and _args(0).is_real_type())
        throw "threshold must be a real scalar";

      // Fetch it
      threshold = _args(1).double_value();
    }

    // Check the first one is a real vector
    if (not (_args(0).is_matrix_type() and _args(0).is_real_type()))
      throw "vector must be a real vector";

    // Get the matrix
    Matrix m = _args(0).matrix_value();

    // Check it is either a row or a column vector
    if (m.rows() != 1 and m.columns() != 1)
      throw "vector must be a real vector";

    // Length
    octave_idx_type length = m.length();

    // Data
    const double* data = m.data();

    // Loop
    octave_idx_type output;
    bool found = false;
    for (octave_idx_type i = DirP::start(length);
         not found and DirP::more(i, length); DirP::next(i)) {
      // Is the condition accomplished?
      if (FallP::active(data[i], data[i + 1], threshold)) {
        // Found!
        output = i;
        found  = true;
      }
    }

    // Prepare output
    result.resize(1);

    // Found?
    if (found)
      result(0) = output + 1;
    else
      result(0) = Matrix();
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


/*************************/
/* Octave glue functions */
/*************************/

// Last downfall
DEFUN_DLD(last_downfall, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function}\
 {[ @var{index} ] =} last_downfall(@var{vector}, [ @var{threshold} ])\n\
\n\
Find the index of the last downfall\n\
@end deftypefn") {
  // Call the schema
  return find_it<Last, Downfall>(args, nargout);
}

// PKG_ADD: autoload('first_downfall', which('last_downfall'));

// First downfall
DEFUN_DLD(first_downfall, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function}\
 {[ @var{index} ] =} first_downfall(@var{vector}, [ @var{threshold} ])\n\
\n\
Find the index of the first downfall\n\
@end deftypefn") {
  // Call the schema
  return find_it<First, Downfall>(args, nargout);
}

// PKG_ADD: autoload('last_uprise', which('last_downfall'));

// Last uprise
DEFUN_DLD(last_uprise, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function}\
 {[ @var{index} ] =} last_uprise(@var{vector}, [ @var{threshold} ])\n\
\n\
Find the index of the last uprise\n\
@end deftypefn") {
  // Call the schema
  return find_it<Last, Uprise>(args, nargout);
}

// PKG_ADD: autoload('first_uprise', which('last_downfall'));

// First uprise
DEFUN_DLD(first_uprise, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function}\
 {[ @var{index} ] =} first_uprise(@var{vector}, [ @var{threshold} ])\n\
\n\
Find the index of the first uprise\n\
@end deftypefn") {
  // Call the schema
  return find_it<First, Uprise>(args, nargout);
}
