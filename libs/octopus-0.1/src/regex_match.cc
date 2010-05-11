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
#include <string>
#include <vector>

#include <octave/oct.h>

#include <boost/regex.hpp>


/******************************/
/* Match a Regular Expression */
/******************************/

DEFUN_DLD(regex_match, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[ @var{match}, @var{submatch}, ... ] =}\
 regex_match(@var{target}, @var{regex})\n\
\n\
Match regular expression @var{regex} to @var{target}\n\
@end deftypefn") {
  // Result
  octave_value_list result;

  try {
    // Check the number of parameters
    if (args.length() != 2 or nargout < 1)
      throw (const char*)0;
	
    // Get target
    if (not args(0).is_string())
      throw "target should be a string";
    std::string target = args(0).string_value();

    // Check regex
    if (not args(1).is_string())
      throw "regex should be a string";
    
    // Create the regular expression
    boost::regex re(args(1).string_value());

    // Match it!
    boost::smatch match;
    if (boost::regex_match(target, match, re)) {
      // Matched
      
      // Set the result to the submatches
      result.resize(nargout);
      for (int i = 0; i < nargout; ++i)
	if (i < match.size())
	  result(i) = match.str(i);
	else
	  result(i) = "";;
    }
    else {
      // No match!
      
      // Set the first to false, and the others remain empty
      result.resize(nargout);
      result(0) = false;
      for (int i = 1; i < nargout; ++i)
	result(i) = "";
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


/*******************************/
/* Search a Regular Expression */
/*******************************/

// PKG_ADD: autoload('regex_search', which('regex_match'));

DEFUN_DLD(regex_search, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[ @var{match}, @var{submatch}, ... ] =}\
 regex_search(@var{target}, @var{regex})\n\
\n\
Search regular expression @var{regex} in @var{target}\n\
@end deftypefn") {
  // Result
  octave_value_list result;

  try {
    // Check the number of parameters
    if (args.length() != 2 or nargout < 1)
      throw (const char*)0;
	
    // Get target
    if (not args(0).is_string())
      throw "target should be a string";
    std::string target = args(0).string_value();

    // Check regex
    if (not args(1).is_string())
      throw "regex should be a string";
    
    // Create the regular expression
    boost::regex re(args(1).string_value());

    // Search it!
    boost::smatch match;
    if (boost::regex_search(target, match, re)) {
      // Matched
      
      // Set the result to the submatches
      result.resize(nargout);
      for (int i = 0; i < nargout; ++i)
	if (i < match.size())
	  result(i) = match.str(i);
	else
	  result(i) = "";
    }
    else {
      // No match!
      
      // Set the first to false, and the others remain empty
      result.resize(nargout);
      result(0) = false;
      for (int i = 1; i < nargout; ++i)
	result(i) = "";
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


/*********************************/
/* Split by a Regular Expression */
/*********************************/

// PKG_ADD: autoload('regex_split', which('regex_match'));

DEFUN_DLD(regex_split, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[ @var{fields} ] =}\
 regex_split(@var{target}, @var{regex})\n\
\n\
Split @var{target} by regular expression @var{regex}\n\
@end deftypefn") {
  // Result
  octave_value_list result;

  try {
    // Check the number of parameters
    if (args.length() != 2 or nargout != 1)
      throw (const char*)0;
	
    // Get target
    if (not args(0).is_string())
      throw "target should be a string";
    std::string target = args(0).string_value();
    
    // Check regex
    if (not args(1).is_string())
      throw "regex should be a string";
    
    // Create the regular expression
    boost::regex re(args(1).string_value());

    // Fields
    std::vector<std::string> fields;

    // Match it!
    boost::sregex_token_iterator i =
      boost::make_regex_token_iterator(target, re, -1);
    boost::sregex_token_iterator end;
    while (i != end)
      fields.push_back(*i++);

    // Set
    Cell c(1, fields.size());
    for (int f = 0; f < fields.size(); ++f)
      c(f) = fields[f];

    // Result
    result.resize(1);
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
