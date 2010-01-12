#include <exception>
#include <string>

#include <octave/oct.h>

#include <boost/regex.hpp>


/******************************/
/* Match a Regular Expression */
/******************************/

DEFUN_DLD(regex_match, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[ @var{match}, @var{submatch}, ... ] =} regex_match(@var{target}, @var{regex})\n\
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


/******************************/
/* Search a Regular Expression */
/******************************/

DEFUN_DLD(regex_search, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[ @var{match}, @var{submatch}, ... ] =} regex_search(@var{target}, @var{regex})\n\
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
