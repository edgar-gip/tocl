#include <algorithm>
#include <cstdlib>
#include <exception>
#include <iostream>
#include <list>
#include <memory>
#include <string>

#include <octave/oct.h>

#include <boost/regex.hpp>

#include <ttcl/io/anystream.hxx>


/*************************************/
/* Read the seeds from a result file */
/*************************************/

DEFUN_DLD(read_seeds, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function}\
 {[ @var{seeds} ] =} read_seeds(@var{file})\n\
\n\
Read the seeds from a result file\n\
@end deftypefn") {
  // Result
  octave_value_list result;

  try {
    // Check the number of parameters
    if (args.length() != 1 or nargout != 1) {
      print_usage();
      return octave_value_list();
    }
  
    // Get file
    if (not args(0).is_string())
      throw "file should be a string";
    std::string file = args(0).string_value();

    // The stream
    std::auto_ptr<std::istream> is(ttcl::io::ianystream::open(file.c_str()));

    // The seeds
    std::list<int> seeds;

    // Regular expression
    static boost::regex seeds_re("# Run: #(\\d+) Seeds: (\\d+), (\\d+)");

    // Read each line
    std::string line;
    while (std::getline(*is, line)) {
      // Starts with #
      /* Trying to save some time by a simple comparison
       */
      if (line[0] == '#') {
	// Match it
	boost::smatch match;
	if (boost::regex_match(line, match, seeds_re)) {
	  // Matched -> Add it
	  seeds.push_back(atoi(match.str(2).c_str()));
	  seeds.push_back(atoi(match.str(3).c_str()));
	}
      }
    }
	
    // Convert to matrix
    Matrix m(2, seeds.size() / 2);
    std::copy(seeds.begin(), seeds.end(), m.fortran_vec());

    // Set the result
    result.resize(nargout);
    result(0) = m;
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
