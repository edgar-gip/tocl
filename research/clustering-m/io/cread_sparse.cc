#include <octave/oct.h>

#include <cctype>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <map>
#include <set>
#include <vector>
using namespace std;

// Buffer sizes
#define MAX_LINE_LENGTH 2048
#define MAX_ID_LENGTH   32

// Normalization modes
enum nmode { nmode_no, nmode_sum, nmode_euclid };

// Internal function to load sparse matrices
DEFUN_DLD(cread_sparse, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[...] =} cread_sparse(@var{file} [, @var{normalization}])\n\
\n\
Internal function to help in loading sparse matrices.\n\
\n\
Possible normalization values: 'no', 'sum', 'euclid'\n\
@end deftypefn") {
  // Buffer
  char buffer  [MAX_LINE_LENGTH];
  char filename[MAX_LINE_LENGTH];

  // Check the parameter
  if (args.length() < 1 || args.length() > 2 ||
      !args(0).is_string()) {
    print_usage("cread_sparse");
    return octave_value_list();
  }

  // Normalization mode
  nmode  normMode   = nmode_no;
  string modeString = args(1).string_value();
  if (args.length() == 2) {
    if (modeString == "sum") {
      normMode = nmode_sum;
    } else if (modeString == "euclid") {
      normMode = nmode_euclid;
    } else if (modeString != "no") {
      print_usage("cread_sparse");
    }
  }

  // Open the file
  strcpy(filename, args(0).string_value().c_str());
  FILE* file = fopen(filename, "r");
  if (!file) {
    error("cread_sparse: cannot open file %s", filename);
    return octave_value_list();
  }

  // Read the header
  if (!fgets(buffer, MAX_LINE_LENGTH, file)) {
    error("cread_sparse: premature end of input");
    fclose(file);
    return octave_value_list();
  }

  // Parse
  int nrows, ncols, nnz;
  if (sscanf(buffer, "%d %d %d", &nrows, &ncols, &nnz) < 3) {
    error("cread_sparse: ill formed header '%s' at %s:1",
          buffer, filename);
    fclose(file);
  }

  // Now, reserve three vectors
  ColumnVector rows(nnz);
  ColumnVector cols(nnz);
  ColumnVector vals(nnz);

  // Current filling position
  int i = 0;

  // Current row
  int r = 1;

  // Auxiliary vars
  char *p, *q, *perr;
  unsigned long int col;
  double val;
  double total;
  bool   more;
  int    startI;

  // Read every line
  while(fgets(buffer, MAX_LINE_LENGTH, file)) {
    // Process
    p      = buffer;
    total  = 0.0;
    more   = true;
    startI = i;

    while (more) {
      // Skip blank
      while (*p && isspace(*p)) ++p;
      if (!*p) break;

      // Keep the pos
      q = p++;
      while(*p && !isspace(*p)) ++p;

      // Finished?
      if (!*p) {
        error("cread_sparse: ill formed line (no value) at %s:%d",
              filename, r + 1);
        fclose(file);
        return octave_value_list();
      }

      // Parse
      *p++ = '\0';
      col = strtoul(q, &perr, 10);
      if (*perr) {
        error("cread_sparse: ill formed line (wrong column format '%s') at %s:%d",
              q, filename, r + 1);
        fclose(file);
        return octave_value_list();
      }

      // Skip blank
      while (*p && isspace(*p)) ++p;
      if (!*p) {
        error("cread_sparse: ill formed line (no value) at %s:%d",
              filename, r + 1);
        fclose(file);
        return octave_value_list();
      }

      // Keep the pos
      q = p++;
      while(*p && !isspace(*p)) ++p;

      if (!*p) {
        more = false;
      } else {
        *p++ = '\0';
      }

      // Parse
      val = strtod(q, &perr);
      if (*perr) {
        error("cread_sparse: ill formed line (wrong value format '%s') at %s:%d",
              q, filename, r + 1);
        fclose(file);
        return octave_value_list();
      }

      // Debug
      // printf("(%d,%d) = %g\n", r, col, val);

      // If everything went fine, add it to the matrix
      rows(i) = r;
      cols(i) = col;
      vals(i) = val;
      ++i;

      // Normalization
      switch(normMode) {
      case nmode_no:     break;
      case nmode_sum:    total += val; break;
      case nmode_euclid: total += val * val;
      }
    }

    // Normalization
    if (normMode != nmode_no) {
      if (normMode == nmode_euclid)
        total = sqrt(total);

      for (int ti = startI; ti < i; ++ti)
        vals(ti) /= total;
    }

    // Next row
    ++r;
  }

  // Error or EOF?
  if (ferror(file)) {
    error("cread_sparse: input error at %s:%d",
          filename, r + 1);
    fclose(file);
    return octave_value_list();
  }

  // Free
  fclose(file);

  // Enough data read?
  if (i < nnz) {
    error("cread_sparse: not enough data at %s:%d", filename, r + 1);
    return octave_value_list();
  }

  // Everything seems fine
  octave_value_list output;
  output.resize(6);
  output(0) = octave_value(rows);
  output(1) = octave_value(cols);
  output(2) = octave_value(vals);
  output(3) = octave_value(nrows);
  output(4) = octave_value(ncols);;
  output(5) = octave_value(nnz);;
  return output;
}


// Internal function to load sparse matrices
DEFUN_DLD(cread_sparse_idf, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[...] =} cread_sparse_idf(@var{file})\n\
\n\
Internal function to help in loading sparse matrices.\n\
@end deftypefn") {
  // Buffer
  char buffer  [MAX_LINE_LENGTH];
  char filename[MAX_LINE_LENGTH];

  // Check the parameter
  if (args.length() != 1 || !args(0).is_string()) {
    print_usage("cread_sparse_idf");
    return octave_value_list();
  }

  // Open the file
  strcpy(filename, args(0).string_value().c_str());
  FILE* file = fopen(filename, "r");
  if (!file) {
    error("cread_sparse_idf: cannot open file %s", filename);
    return octave_value_list();
  }

  // Read the header
  if (!fgets(buffer, MAX_LINE_LENGTH, file)) {
    error("cread_sparse_idf: premature end of input");
    fclose(file);
    return octave_value_list();
  }

  // Parse
  int nrows, ncols, nnz;
  if (sscanf(buffer, "%d %d %d", &nrows, &ncols, &nnz) < 3) {
    error("cread_sparse_idf: ill formed header '%s' at %s:1",
          buffer, filename);
    fclose(file);
  }

  // Now, reserve four vectors
  vector<int>  rows(nnz, 0);
  vector<int>  cols(nnz, 0);
  ColumnVector vals(nnz);
  vector<int>  df  (ncols, 0);

  // Current filling position
  int i = 0;

  // Current row
  int r = 1;

  // Auxiliary vars
  char *p, *q, *perr;
  unsigned long int col;
  double val;
  bool   more;

  // Read every line
  while(fgets(buffer, MAX_LINE_LENGTH, file)) {
    // Process
    p      = buffer;
    more   = true;

    while (more) {
      // Skip blank
      while (*p && isspace(*p)) ++p;
      if (!*p) break;

      // Keep the pos
      q = p++;
      while(*p && !isspace(*p)) ++p;

      // Finished?
      if (!*p) {
        error("cread_sparse_idf: ill formed line (no value) at %s:%d",
              filename, r + 1);
        fclose(file);
        return octave_value_list();
      }

      // Parse
      *p++ = '\0';
      col = strtoul(q, &perr, 10);
      if (*perr) {
        error("cread_sparse_idf: ill formed line (wrong column format '%s') at %s:%d",
          q, filename, r + 1);
        fclose(file);
        return octave_value_list();
      }

      // Skip blank
      while (*p && isspace(*p)) ++p;
      if (!*p) {
        error("cread_sparse_idf: ill formed line (no value) at %s:%d",
          filename, r + 1);
        fclose(file);
        return octave_value_list();
      }

      // Keep the pos
      q = p++;
      while(*p && !isspace(*p)) ++p;

      if (!*p) {
        more = false;
      } else {
        *p++ = '\0';
      }

      // Parse
      val = strtod(q, &perr);
      if (*perr) {
        error("cread_sparse_idf: ill formed line (wrong value format '%s') at %s:%d",
          q, filename, r + 1);
        fclose(file);
        return octave_value_list();
      }

      // Debug
      // printf("(%d,%d) = %g\n", r, col, val);

      // If everything went fine, add it to the matrix
      rows[i] = r;
      cols[i] = col;
      vals(i) = val;
      ++i;

      // Update df
      ++df[col];
    }

    // Next row
    ++r;
  }

  // Error or EOF?
  if (ferror(file)) {
    error("cread_sparse_idf: input error at %s:%d",
          filename, r + 1);
    fclose(file);
    return octave_value_list();
  }

  // Free
  fclose(file);

  // Enough data read?
  if (i < nnz) {
    error("cread_sparse_idf: not enough data at %s:%d", filename, r + 1);
    return octave_value_list();
  }

  // TfIdf normalization
  // First, convert idf to what should be
  vector<double> idf;
  idf.reserve(ncols);

  double lrows = log(double(nrows));
  for (vector<int>::iterator it = df.begin();
       it != df.end(); ++it) {
    idf.push_back(lrows - log(double(*it)));
  }

  // Then, transform and normalize each vector
  // Output colum vectors
  ColumnVector drows(nnz);
  ColumnVector dcols(nnz);

  // Follow all positions
  r = rows[0];
  int startI = 0;
  double total = 0.0;

  for (i = 0; i < nnz; ++i) {
    if (rows[i] != r) {
      // Find the square root
      total = sqrt(total);

      // Normalize
      for (int ti = startI; ti < i; ++ti)
        vals(ti) /= total;

      // Reset
      r      = rows[i];
      startI = i;
      total  = 0.0;
    }

    // Normalize
    vals(i) *= idf[cols[i]];

    // Add it
    total += vals(i);

    // Convert to double
    drows(i) = double(rows[i]);
    dcols(i) = double(cols[i]);
  }

  // The last one
  // Find the square root
  total = sqrt(total);

  // Normalize
  for (int ti = startI; ti < nnz; ++ti)
    vals(ti) /= total;

  // Everything seems fine
  octave_value_list output;
  output.resize(6);
  output(0) = octave_value(drows);
  output(1) = octave_value(dcols);
  output(2) = octave_value(vals);
  output(3) = octave_value(nrows);
  output(4) = octave_value(ncols);;
  output(5) = octave_value(nnz);;
  return output;
}


// Internal function to load DOC_TO_CAT
DEFUN_DLD(cread_labels, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[...] =} cread_labels(@var{rlabel_file}, @var{doc2cat_file}])\n\
\n\
Load the document labels as string matrices.\n\
@end deftypefn") {
  // Buffer
  char buffer  [MAX_LINE_LENGTH];
  char filename[MAX_LINE_LENGTH];

  // Check the parameter
  if (args.length() != 2 || !args(0).is_string() ||
      !args(1).is_string()) {
    print_usage("cread_labels");
    return octave_value_list();
  }

  // Open the doc2cat file
  strcpy(filename, args(1).string_value().c_str());
  FILE* file = fopen(filename, "r");
  if (!file) {
    error("cread_labels: cannot open file %s", filename);
    return octave_value_list();
  }

  // Doc2cat map
  map<string, string> doc2cat;
  char docId  [MAX_ID_LENGTH];
  char labelId[MAX_ID_LENGTH];

  // Read doc2cat
  int line = 1;
  while(fgets(buffer, MAX_LINE_LENGTH, file)) {
    if (sscanf(buffer, "%s %s", docId, labelId) < 2) {
      error("cread_labels: wrong line format at %s:%d",
            filename, line);
      return octave_value_list();
    }

    // Keep the first found category
    if (doc2cat.find(docId) == doc2cat.end()) {
      doc2cat[docId] = labelId;
    }

    ++line;

    // Debug
    // printf("%s -> %s\n", docId, labelId);
  }

  // Error or EOF?
  if (ferror(file)) {
    error("cread_labels: input error at %s:%d",
          filename, line);
    fclose(file);
    return octave_value_list();
  }

  // Close
  fclose(file);

  // Open the rlabel file
  strcpy(filename, args(0).string_value().c_str());
  file = fopen(filename, "r");
  if (!file) {
    error("cread_labels: cannot open file %s", filename);
    return octave_value_list();
  }

  // Output1 : Category for each document
  string_vector output1;

  // Present
  set<string> present;

  // Read rlabel
  line = 1;
  while(fgets(buffer, MAX_LINE_LENGTH, file)) {
    if (sscanf(buffer, "%s", docId) < 1) {
      error("cread_labels: wrong line format at %s:%d",
            filename, line);
      return octave_value_list();
    }
    output1.append(doc2cat[docId]);
    present.insert(doc2cat[docId]);
    ++line;
  }

  // Error or EOF?
  if (ferror(file)) {
    error("cread_labels: input error at %s",
          filename);
    fclose(file);
    return octave_value_list();
  }

  // Close
  fclose(file);

  // Output2 : Present categories
  string_vector output2;
  for (set<string>::iterator it = present.begin();
       it != present.end(); ++it) {
    output2.append(*it);
  }

  // Return the cell
  octave_value_list output;
  output.resize(2);
  output(0) = octave_value(output1);
  output(1) = octave_value(output2);
  return output;
}


// Function to load DOC_TO_CAT in a numerical way
DEFUN_DLD(read_labels_num, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[ Labels nLabels ] =} read_labels_num(@var{rlabel_file}, @var{doc2cat_file}])\n\
\n\
Load the document labels as a column vector.\n\
@end deftypefn") {
  // Buffer
  char buffer  [MAX_LINE_LENGTH];
  char filename[MAX_LINE_LENGTH];

  // Check the parameter
  if (args.length() != 2 || !args(0).is_string() ||
      !args(1).is_string()) {
    print_usage("read_labels_num");
    return octave_value_list();
  }

  // Open the doc2cat file
  strcpy(filename, args(1).string_value().c_str());
  FILE* file = fopen(filename, "r");
  if (!file) {
    error("read_labels_num: cannot open file %s", filename);
    return octave_value_list();
  }

  // Doc2cat map
  map<string, string> doc2cat;
  char docId  [MAX_ID_LENGTH];
  char labelId[MAX_ID_LENGTH];

  // Read doc2cat
  int line = 1;
  while(fgets(buffer, MAX_LINE_LENGTH, file)) {
    if (sscanf(buffer, "%s %s", docId, labelId) < 2) {
      error("read_labels_num: wrong line format at %s:%d",
            filename, line);
      return octave_value_list();
    }

    // Keep the first found category
    if (doc2cat.find(docId) == doc2cat.end()) {
      doc2cat[docId] = labelId;
    }

    ++line;

    // Debug
    // printf("%s -> %s\n", docId, labelId);
  }

  // Error or EOF?
  if (ferror(file)) {
    error("read_labels_num: input error at %s:%d",
          filename, line);
    fclose(file);
    return octave_value_list();
  }

  // Close
  fclose(file);

  // Open the rlabel file
  strcpy(filename, args(0).string_value().c_str());
  file = fopen(filename, "r");
  if (!file) {
    error("read_labels_num: cannot open file %s", filename);
    return octave_value_list();
  }

  // Category for each document
  vector<int> docCats;

  // Number of Categories
  int numCats = 0;

  // Present
  map<string, int> present;

  // Read rlabel
  line = 1;
  while(fgets(buffer, MAX_LINE_LENGTH, file)) {
    if (sscanf(buffer, "%s", docId) < 1) {
      error("read_labels_num: wrong line format at %s:%d",
            filename, line);
      return octave_value_list();
    }

    map<string, int>::iterator it =
      present.find(doc2cat[docId]);

    if (it == present.end()) {
      // Not found
      present[doc2cat[docId]] = numCats;
      docCats.push_back(numCats++);

    } else {
      // Found
      docCats.push_back(it->second);
    }
    ++line;
  }

  // Error or EOF?
  if (ferror(file)) {
    error("read_labels_num: input error at %s",
          filename);
    fclose(file);
    return octave_value_list();
  }

  // Close
  fclose(file);

  // Create a column vector
  ColumnVector output1(docCats.size());
  for (int i = 0; i < docCats.size(); ++i)
    output1(i) = docCats[i];

  // Return the cell
  octave_value_list output;
  output.resize(2);
  output(0) = octave_value(output1);
  output(1) = octave_value(numCats);
  return output;
}


// Function to load clusterings
DEFUN_DLD(read_clustering, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[...] =} read_clustering(@var{file})\n\
\n\
Load a clustering.\n\
@end deftypefn") {
  // Buffer
  char buffer  [MAX_LINE_LENGTH];
  char filename[MAX_LINE_LENGTH];

  // Check the parameter
  if (args.length() != 1 || !args(0).is_string()) {
    print_usage("cread_clustering");
    return octave_value_list();
  }

  // Open the file
  strcpy(filename, args(0).string_value().c_str());
  FILE* file = fopen(filename, "r");
  if (!file) {
    error("cread_clustering: cannot open file %s", filename);
    return octave_value_list();
  }

  // Now, reserve a vector
  vector<int> clustering;

  // Different clusters
  int k = -1;

  // Current row
  int r = 1;

  // Auxiliary vars
  char *p, *q, *perr;
  unsigned long int col;
  double val;
  bool   more;

  // Read every line
  while(fgets(buffer, MAX_LINE_LENGTH, file)) {
    // Current cluster
    int cluster;

    // Process
    if (!sscanf(buffer, "%d", &cluster)) {
      error("cread_clustering: ill formed line (not an integer) at %s:%d",
            filename, r);
      fclose(file);
      return octave_value_list();
    }

    // Update k?
    if (cluster > k)
      k = cluster;

    // Add it
    clustering.push_back(cluster);

    // Next row
    ++r;
  }

  // Error or EOF?
  if (ferror(file)) {
    error("cread_clustering: input error at %s:%d",
          filename, r);
    fclose(file);
    return octave_value_list();
  }

  // Free
  fclose(file);

  // Output colum vector
  ColumnVector dclust(clustering.size());

  // Convert to double
  for (int i = 0; i < clustering.size(); ++i) {
    dclust(i) = double(clustering[i]);
  }

  // Everything seems fine
  octave_value_list output;
  output.resize(2);
  output(0) = octave_value(dclust);
  output(1) = octave_value(k + 1);
  return output;
}
