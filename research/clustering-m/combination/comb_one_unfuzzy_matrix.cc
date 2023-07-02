#include <octave/oct.h>
#include <octave/ov-struct.h>

#include <cstdio>
#include <map>
#include <string>

using namespace std;


// Buffer sizes
#define MAX_LINE_LENGTH 2048

/******************/
/* Unfuzzy matrix */
/******************/

// Fill an unfuzzy matrix
bool fillUnfuzzy(Matrix& unfuzzy,
                 string_vector& labels,
                 Matrix& clustering,
                 string rlabel) {
  // Line buffer
  char buffer[MAX_LINE_LENGTH];

  // Open the file
  FILE* file = fopen(rlabel.c_str(), "r");
  if (!file) {
    error("cannot open file %s", rlabel.c_str());
    return false;
  }

  // Map
  map<string, int> docMap;
  int nDocs = 0;

  // NData
  int nData = clustering.rows();

  // Read every line
  int line = 1;
  while (fgets(buffer, MAX_LINE_LENGTH, file)) {
    // Check
    if (line > nData) {
      error("too many rows in rlabel file at %s:%d",
            rlabel.c_str(), line);
      fclose(file);
      return false;
    }

    // Find the end
    int len = strlen(buffer);
    if (len == 0) {
      error("empty line at %s:%d", rlabel.c_str(), line);
      fclose(file);
      return false;
    }

    // Trim whitespace
    char* end = buffer + len - 1;
    while (isspace(*end)) {
      if (end == buffer) {
        error("empty line at %s:%d", rlabel.c_str(), line);
        fclose(file);
        return false;
      }
      --end;
    }

    // Find the end of numbers
    char *p = end;
    while (isdigit(*p)) {
      if (p == buffer) {
        error("ill-formed line (all numbers) at %s:%d", rlabel.c_str(), line);
        return false;
      }
      --p;
    }

    // Is it an S or X?
    // Is there no prefix?
    if (*p != 'S' && *p != 's' && *p != 'X' && *p != 'x') {
      error("ill-formed line (no separator) at %s:%d", rlabel.c_str(), line);
      return false;
    }

    // Change it to a 0
    *p = '\0';

    // Beginning
    char* begin = buffer;
    while (*begin && isspace(*begin))
      ++begin;

    // Empty prefix?
    if (begin == p) {
      error("ill-formed line (empty prefix) at %s:%d", rlabel.c_str(), line);
      return false;
    }

    // Find?
    string doc = string(begin);
    map<string, int>::iterator it = docMap.find(doc);
    if (it == docMap.end()) {
      // New doc
      docMap.insert(make_pair(doc, nDocs++));
      labels.append(doc);
    }

    // Assign matrix
    ++unfuzzy(docMap[doc], int(clustering(line - 1)));

    // Next line
    ++line;
  }

  // Error or EOF?
  if (ferror(file)) {
    error("input error at %s:%d", rlabel.c_str(), line);
    fclose(file);
    return false;
  }

  // Free
  fclose(file);

  // Extract
  unfuzzy = unfuzzy.extract(0, 0, nDocs - 1, unfuzzy.cols() - 1);

  // Everything OK
  return true;
}



/*******************/
/* Octave-C++ Glue */
/*******************/

// Find the unfuzzy matrix
DEFUN_DLD(comb_one_unfuzzy_matrix, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[Matrix, Labels] =} comb_one_unfuzzy_matrix(@var{clustering}, @var{nclusters}, @var{rlabel_file})\n\
\n\
Find the unfuzzy matrix for one clustering.\n\
@end deftypefn") {
  // Check argument number
  if (args.length() != 3 || nargout > 2) {
    print_usage("comb_one_unfuzzy_matrix");
    return octave_value_list();
  }

  // Check types of arguments
  if (!args(0).is_real_matrix()) {
    error("CLUSTERING should be a column vector");
    return octave_value_list();
  }

  if (!args(1).is_real_scalar()) {
    error("NCLUSTERS should be a scalar");
    return octave_value_list();
  }

  if (!args(2).is_string()) {
    error("RLABEL_FILE should be a filename");
    return octave_value_list();
  }

  // Check dimensions of CLUSTERING
  Matrix clustering = args(0).matrix_value();
  if (clustering.cols() != 1) {
    error("CLUSTERING should be a column vector");
    return octave_value_list();
  }

  // Sizes
  int nData  = clustering.rows();
  int nClust = args(1).int_value();

  // String
  string rlabel = args(2).string_value();

  // Return values
  Matrix        unfuzzy(nData, nClust, 0.0);
  string_vector labels;

  // Call the function
  if (!fillUnfuzzy(unfuzzy, labels, clustering, rlabel))
    return octave_value_list();

  // Return
  octave_value_list output;
  output.resize(2);
  output(0) = octave_value(unfuzzy);
  output(1) = octave_value(Cell(labels));
  return output;
}
