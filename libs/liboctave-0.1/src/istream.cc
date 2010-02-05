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
#include <iostream>
#include <memory>
#include <string>

#include <octave/oct.h>

#include <ttcl/io/anystream.hxx>

#include <octave_c_ptr_value.h>


/************************/
/* Istream octave value */
/************************/

typedef octave_c_pointer_value<std::istream> istream_value;
octave_c_pointer_static(std::istream, "std_istream");


/******************/
/* Open a istream */
/******************/

// PKG_ADD: autoload('istream_open', which('istream'));

DEFUN_DLD(istream_open, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[ @var{istream} ] =} istream_open(@var{file})\n\
\n\
Open a istream\n\
@end deftypefn") {
  // Result
  octave_value_list result;

  try {
    // Check the number of parameters
    if (nargout != 1)
      throw (const char*)0;

    // Get file
    if (not args(0).is_string())
      throw "file should be a string";
    std::string file = args(0).string_value();

    // The stream
    std::auto_ptr<std::istream> is(ttcl::io::ianystream::open(file.c_str()));

    // Pack
    result.resize(nargout);
    result(0) = new istream_value(is.release());
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
  

/******************************/
/* Read a line from a istream */
/******************************/

// PKG_ADD: autoload('istream_readline', which('istream'));

DEFUN_DLD(istream_readline, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[ @var{line} ] =} \
istream_readline(@var{istream})\n\
\n\
Read a line from a istream\n\
@end deftypefn") {
  // Result
  octave_value_list result;

  try {
    // Check the number of parameters
    if (nargout != 1)
      throw (const char*)0;

    // Get istream
    if (args(0).type_id() != istream_value::static_type_id())
      throw "istream should be a istream";

    // Cast
    istream_value* is = static_cast<istream_value*>(args(0).internal_rep());
    if (not is)
      throw "istream cannot be null";

    // Read a line
    std::string line;
    std::getline(is->data(), line);

    // Result
    result.resize(nargout);
    
    // OK?
    if (is->data().good())
      result(0) = line;
    else
      result(0) = false;
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
