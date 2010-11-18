#include <cmath>
#include <exception>
// #include <iostream>

#include <octave/oct.h>

// Octave callback
DEFUN_DLD(gaussian_expectation, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function}\
 {[ @var{expec}, @var{log_like} ] =} gaussian_expectation\
(@var{pvar}, @var{mean}, @var{var}, @var{data})\n\
\n\
Find the \n\
@end deftypefn") {
  // Result
  octave_value_list result;

  try {
    // Check the number of parameters
    if (args.length() != 4 or nargout != 2)
      throw (const char*)0;

    // Do it...
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
