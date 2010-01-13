#include <algorithm>
#include <fstream>
#include <iostream>
#include <memory>
#include <sstream>
#include <string>
#include <utility>
#include <vector>

#include <ttcl/io/anystream.hxx>

#include <octave/oct.h>

using namespace std;

// Target structure
struct redo_info {
  // Number of fields
  static const int n_fields = 10;

  // Fields
  double fields[n_fields];

  // Constructor
  redo_info() {
    // Set to zero
    fill(fields, fields + n_fields, 0.0);
  }

  // Constructor from a line
  redo_info(const string& _line) {
    // For each field
    string::size_type st = 0;
    int                f = 0;
    for (; f < n_fields; ++f) {
      // Find a space
      string::size_type end = _line.find(' ', st);

      // Parse
      fields[f] = atof(_line.c_str() + st);

      // Found?
      if (end == string::npos) {
	// End!
	break;
      }
      else {
	// Move
	st = end + 1;
      }
    }

    // Any remain? -> Set them to zero
    for (; f < n_fields; ++f)
      fields[f] = 0.0;
  }
};

// Read a redo file
DEFUN_DLD(read_redo, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[ @var{info} ] =}\
 read_redo(@var{file}, @var{header})\n\
\n\
Read a the contents of a redo file section from a file\n\
@end deftypefn") {
  // Result
  octave_value_list result;

  try {
    // Check the number of parameters
    if (args.length() != 2 or nargout != 1)
      throw (const char*)0;

    // Check the first argument
    if (not args(0).is_string())
      throw "@var{file} should be a string";

    // Check the second argument
    if (not args(1).is_string())
      throw "@var{header} should be a string";

    // Open the file
    auto_ptr<istream> is
      (ttcl::io::ianystream::open(args(0).string_value().c_str()));

    // Target Header
    string target_header = "# " + args(1).string_value();

    // Information
    vector<redo_info> information;

    // Read
    bool inside = false;
    string line;
    while (getline(*is, line)) {
      // Non-empty line
      if (not line.empty()) {
	// Is it a header?
	if (line[0] == '#') {
	  // Were we inside?
	  if (inside) {
	    // Done
	    break;
	  }
	  else {
	    // We are inside if we enter the target header
	    inside = line == target_header;
	  }
	}
	// Regular line -> Are we inside?
	else if (inside) {
	  // Split it
	  information.push_back(redo_info(line));
	}
      }
    }
	
    // Convert to an octave Matrix
    Matrix m(information.size(), redo_info::n_fields);
    for (int i = 0; i < information.size(); ++i)
      for (int f = 0; f < redo_info::n_fields; ++f)
	m(i, f) = information[i].fields[f];

    // Result
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
  catch (ttcl::exception& _e) {
    // Display the error
    error(_e.c_message());
  }

  // That's all!
  return result;
}
