#include <octave/oct.h>

/****************/
/* Append cells */
/****************/

DEFUN_DLD(cellcat, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[ @var{cell} ] =} cellcat(@var{cell}, ...)\n\
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

DEFUN_DLD(cellpush, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[ @var{cell} ] =} cellcat(@var{cell}, ...)\n\
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

DEFUN_DLD(celltail, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[ @var{cell} ] =} celltail(@var{cell})\n\
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
