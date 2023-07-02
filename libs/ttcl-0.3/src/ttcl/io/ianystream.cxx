#include <ttcl/io/ianystream.hxx>

#include <cstring>
#include <fstream>
#include <iostream>

#include <ttcl/exception.hxx>
#include <ttcl/io/bzstream.hxx>
#include <ttcl/io/gzstream.hxx>

using namespace std;
using namespace ttcl;
using namespace ttcl::io;

// Any input stream

/// Open a file
istream* ianystream::
open(const char* _filename, ios::openmode _mode) {
  // Ensure mode is not out
  if (_mode & ios::out)
    TTCL_FIRE("Can't open a ianystream in ios::out mode");

  // Ensure mode is in
  _mode |= ios::in;

  // Length
  int length = strlen(_filename);

  // Filename ends in .gz or .tgz?
  if ((length > 3 and
       not strcmp(_filename + length - 3, ".gz")) or
      (length > 4 and
       not strcmp(_filename + length - 4, ".tgz"))) {
    // Open gzip-compressed
    igzstream* igzs = new igzstream(_filename, _mode);
    if (not igzs->is_open()) {
      delete igzs;
      TTCL_FIRE("Cannot open %s", _filename);
    }
    return igzs;
  }
  // Filename ends in .bz2 or .tbz or .tb2?
  else if (length > 4 and
           (not strcmp(_filename + length - 4, ".bz2") or
            not strcmp(_filename + length - 4, ".tbz") or
            not strcmp(_filename + length - 4, ".tb2"))) {
    // Open bzip2-compressed
    ibzstream* ibzs = new ibzstream(_filename, _mode);
    if (not ibzs->is_open()) {
      delete ibzs;
      TTCL_FIRE("Cannot open %s", _filename);
    }
    return ibzs;
  }
  // Otherwise
  else {
    // Just open
    ifstream* ifs = new ifstream(_filename, _mode);
    if (not ifs->is_open()) {
      delete ifs;
      TTCL_FIRE("Cannot open %s", _filename);
    }
    return ifs;
  }
}

/// Open a file
ifstream* ianystream::
open_raw(const char* _filename, ios::openmode _mode) {
  // Just open
  ifstream* ifs = new ifstream(_filename, _mode);
  if (not ifs->is_open()) {
    delete ifs;
    TTCL_FIRE("Cannot open %s", _filename);
  }
  return ifs;
}
