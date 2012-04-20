#ifndef TTCL_IO_GZSTREAM_HXX
#define TTCL_IO_GZSTREAM_HXX

// TTCL: The Template Clustering Library

/** @file
    Input/Output - Zlib-Based Streams
    @author Deepak Bandyopadhyay, Lutz Kettner, Edgar Gonzalez i Pellicer
*/

#include <zlib.h>

#include <cstring>
#include <iostream>
#include <fstream>

/// TTCL Namespace
namespace ttcl {

  /// Input/Output Namespace
  namespace io {

    /// Zlib Stream Buffer
    class gzstreambuf :
      public std::streambuf {
    private:
      /// Size of data buffer
      /** Totals 512 bytes under g++ for igzstream at the end.
       */
      static const int bufferSize = 47 + 256;

      /// File handle for compressed file
      gzFile file_;

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
      gzstreambuf();

      /// Destructor
      ~gzstreambuf();

      /// Is it open?
      int
      is_open() const;

      /// Open
      gzstreambuf*
      open(const char* _name, int _open_mode);

      /// Close
      gzstreambuf*
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


    /// Zlib Stream Base
    class gzstreambase :
      virtual public std::ios {
    protected:
      /// Stream buffer
      gzstreambuf buf_;

    public:
      /// Empty Constructor
      gzstreambase();

      /// Constructor
      gzstreambase(const char* _name, int _open_mode);

      /// Destructor
      ~gzstreambase();

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
      gzstreambuf*
      rdbuf();
    };


    /// Input Zlib Stream
    class igzstream :
      public gzstreambase, public std::istream {
    public:
      /// Empty Constructor
      igzstream();

      /// Constructor
      igzstream(const char* _name, int _open_mode = std::ios::in);

      /// Buffer
      gzstreambuf*
      rdbuf();

      /// Open
      void
      open(const char* _name, int _open_mode = std::ios::in);
    };


    //// Output Zlib Stream
    class ogzstream :
      public gzstreambase, public std::ostream {
    public:
      /// Empty Constructor
      ogzstream();

      /// Constructor
      ogzstream(const char* _name, int _open_mode = std::ios::out);

      /// Buffer
      gzstreambuf*
      rdbuf();

      /// Open
      void
      open(const char* _name, int _open_mode = std::ios::out);
    };
  }
}

#endif
