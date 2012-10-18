#include <algorithm>
#include <fstream>
#include <iostream>
#include <memory>
#include <sstream>
#include <string>
#include <utility>
#include <vector>

#include <ttcl/io/ianystream.hxx>

#include <octave/oct.h>

using namespace std;

// Read a sparse matrix from a file
DEFUN_DLD(read_sparse, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[ @var{data}, @var{truth} ] =}\
 read_sparse(@var{file}, @var{has_truth} = false)\n\
\n\
Read a sparse matrix from a file\n\
@end deftypefn") {
  // Result
  octave_value_list result;

  try {
    // Check the number of parameters
    if (args.length() < 1 or args.length() > 2 or nargout < 1 or nargout > 2)
      throw (const char*)0;

    // Check the first argument
    if (not args(0).is_string())
      throw "file should be a string";

    // Get the second argument
    bool has_truth = false;
    if (args.length() > 1) {
      if (not args(1).is_bool_type())
	throw "has_truth should be a boolean if present";
      has_truth = args(1).bool_value();
    }

    // Not has truth and two outputs?
    if (not has_truth and nargout == 2)
      throw "truth is only defined for files with has_truth set to true";

    // Open the file
    auto_ptr<istream> is
      (ttcl::io::ianystream::open(args(0).string_value().c_str()));

    // Skip the header
    string header;
    getline(*is, header);

    // Vectors of everything
    vector<octave_idx_type> rows;
    vector<octave_idx_type> cols;
    vector<double>          values;
    vector<double>          truth;

    // First row
    rows.push_back(0);

    // Read each line
    string line;
    octave_idx_type n_cols = 0;
    while (getline(*is, line)) {
      // Parse each feature
      istringstream iss(line);

      // Truth and entities
      if (has_truth) {
	int cl;
	string dummy;
	iss >> cl >> dummy >> dummy;
	if (nargout > 1)
	  truth.push_back(double(cl));
      }

      // Features
      string feat;
      while (iss >> feat) {
	// Format?
	string::size_type idx = feat.find(':');
	if (idx != string::npos) {
	  feat[idx] = '\0';
	  cols.  push_back(atoi(feat.c_str()));
	  values.push_back(atof(feat.c_str() + (idx + 1)));
	}
	else {
	  cols.  push_back(atoi(feat.c_str()));
	  values.push_back(1.0);
	}
      }

      // One more column (or red nightmare)?
      /* We assume the columns are ordered in the input */
      if (cols.back() >= n_cols) n_cols = cols.back() + 1;

      // Add the row pointer
      rows.push_back(cols.size());
    }

    // Result
    result.resize(nargout);

    // Data matrix
    /* It is created transposed */
    SparseMatrix m_data(n_cols, rows.size() - 1,
			octave_idx_type(values.size()));
    copy(rows  .begin(), rows  .end(), m_data.cidx());
    copy(cols  .begin(), cols  .end(), m_data.ridx());
    copy(values.begin(), values.end(), m_data.data());
    result(0) = m_data;

    // Truth
    if (nargout > 1) {
      RowVector m_truth(truth.size());
      copy(truth.begin(), truth.end(), m_truth.fortran_vec());
      result(1) = m_truth;
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
  // Was there an exception?
  catch (ttcl::exception& _e) {
    // Display the error
    error(_e.c_message());
  }

  // That's all!
  return result;
}
