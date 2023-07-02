#ifndef TTCL_IO_IANYSTREAM_HXX
#define TTCL_IO_IANYSTREAM_HXX

// TTCL: The Template Clustering Library

/** @file
    Input/Output - Open any input file stream
    @author Edgar Gonzalez i Pellicer
*/

#include <cstring>
#include <fstream>
#include <iostream>

#include <ttcl/exception.hxx>
#include <ttcl/io/bzstream.hxx>
#include <ttcl/io/gzstream.hxx>

/// TTCL Namespace
namespace ttcl {

  /// Input/Output Namespace
  namespace io {

    /// Any input stream
    class ianystream {
    public:
      /// Open a file
      static std::istream*
      open(const char* _filename,
           std::ios::openmode _mode = std::ios::in);

      /// Open a file
      static std::ifstream*
      open_raw(const char* _filename,
               std::ios::openmode _mode = std::ios::in);
    };
  }
}

#endif
