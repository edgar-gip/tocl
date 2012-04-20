#ifndef TTCL_IO_BZSTREAM_HXX
#define TTCL_IO_BZSTREAM_HXX

// TTCL: The Template Clustering Library

/** @file
    Input/Output - Bzlib-Based Streams
    Adapted from Zlib-Based Streams
    @author Edgar Gonzalez i Pellicer
*/

#include <bzlib.h>

#include <cstring>
#include <iostream>
#include <fstream>

/// TTCL Namespace
namespace ttcl {

  /// Input/Output Namespace
  namespace io {

    /// Bzlib Stream Buffer
    class bzstreambuf :
      public std::streambuf {
    private:
      /// Size of data buffer
      /** Totals 512 bytes under g++ for igzstream at the end.
       */
      static const int bufferSize = 47 + 256;

      /// File handle for compressed file
      BZFILE* file_;

      /// Data buffer
      char buffer_[bufferSize];

      /// Open/close state of stream
      char opened_;

      /// I/O mode
      int mode_;

      /// Flush buffer
      int
      flush_buffer();

    public:
      /// Constructor
      bzstreambuf();

      /// Destructor
      ~bzstreambuf();

      /// Is it open?
      int
      is_open() const;

      /// Open
      bzstreambuf*
      open(const char* _name, int _open_mode);

      /// Close
      bzstreambuf*
      close();

      /// Overflow
      /** Used for output buffer only
       */
      virtual int
      overflow(int c = EOF);

      /// Underflow
      /** Used for input buffer only
       */
      virtual int
      underflow();

      /// Sync
      virtual int
      sync();
    };


    /// Bzlib Stream Base
    class bzstreambase :
      virtual public std::ios {
    protected:
      /// Stream buffer
      bzstreambuf buf_;

    public:
      /// Empty Constructor
      bzstreambase();

      /// Constructor
      bzstreambase(const char* _name, int _open_mode);

      /// Destructor
      ~bzstreambase();

      /// Is it open?
      int
      is_open() const;

      /// Open
      void
      open(const char* _name, int _open_mode);

      /// Close
      void
      close();

      /// Buffer
      bzstreambuf*
      rdbuf();
    };


    /// Input Bzlib Stream
    class ibzstream :
      public bzstreambase, public std::istream {
    public:
      /// Empty Constructor
      ibzstream();

      /// Constructor
      ibzstream(const char* _name, int _open_mode = std::ios::in);

      /// Buffer
      bzstreambuf*
      rdbuf();

      /// Open
      void
      open(const char* _name, int _open_mode = std::ios::in);
    };


    /// Output Bzlib Stream
    class obzstream :
      public bzstreambase, public std::ostream {
    public:
      /// Empty Constructor
      obzstream();

      /// Constructor
      obzstream(const char* _name, int _open_mode = std::ios::out);

      /// Buffer
      bzstreambuf*
      rdbuf();

      /// Open
      void
      open(const char* _name, int _open_mode = std::ios::out);
    };
  }
}

#endif
