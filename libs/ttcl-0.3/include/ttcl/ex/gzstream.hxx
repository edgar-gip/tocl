#ifndef _TTCL_EX_GZSTREAM_HXX
#define _TTCL_EX_GZSTREAM_HXX

// TTCL: The Template Clustering Library

/** @file
    External Code - Zlib-Based Streams
    @author Deepak Bandyopadhyay, Lutz Kettner, Edgar Gonzalez i Pellicer
*/

#include <zlib.h>

#include <cstring>
#include <iostream>
#include <fstream>

/// TTCL Namespace
namespace ttcl {

  /// External Code Namespace
  namespace ex {

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
      int flush_buffer() {
	// Separate the writing of the buffer from overflow() and
	// sync() operation.
	int w = pptr() - pbase();
	if (gzwrite(file, pbase(), w) != w)
	  return EOF;
	pbump(-w);
	return w;
      }

    public:
      /// Constructor
      gzstreambuf() :
	opened(0) {
        setp(buffer, buffer + (bufferSize-1));
        setg(buffer + 4,     // Beginning of putback area
             buffer + 4,     // Read position
             buffer + 4);    // End position      
      }

      /// Destructor
      ~gzstreambuf() {
	close();
      }

      /// Is it open?
      int is_open() const {
	return opened_;
      }

      /// Open
      gzstreambuf* open(const char* name, int open_mode) {
	// Not open before
	if (is_open())
	  return 0;

	// No append nor read/write mode
	mode = open_mode;
	if ((mode & std::ios::ate) or (mode & std::ios::app)
	    or ((mode & std::ios::in) and (mode & std::ios::out)))
	  return 0;

	// Open
	char  fmode[10];
	char* fmodeptr = fmode;
	if (mode & std::ios::in)
	  *fmodeptr++ = 'r';
	else if (mode & std::ios::out)
	  *fmodeptr++ = 'w';
	*fmodeptr++ = 'b';
	*fmodeptr = '\0';
	file = gzopen(name, fmode);
	if (file == 0)
	  return 0;
	opened = 1;

	// Return this
	return this;
      }

      /// Close
      gzstreambuf* close() {
	// Sync and close
	if (is_open()) {
	  sync();
	  opened = 0;
	  if (gzclose(file) == Z_OK)
            return this;
	}

	// Return null
	return 0;
      }

      /// Overflow
      /** Used for output buffer only
       */
      virtual int overflow(int c = EOF) {
	if (not (mode & std::ios::out) or not opened)
	  return EOF;

	if (c != EOF) {
	  *pptr() = c;
	  pbump(1);
	}

	if (flush_buffer() == EOF)
	  return EOF;

	return c;
      }

      /// Underflow
      /** Used for input buffer only
       */
      virtual int underflow() {
	// Something in the buffer
	if (gptr() and gptr() < egptr())
	  return *reinterpret_cast<unsigned char*>(gptr());

	// Check mode and opened
	if (not (mode & std::ios::in) or not opened)
	  return EOF;

	// Josuttis' implementation of inbuf
	int n_putback = gptr() - eback();
	if (n_putback > 4)
	  n_putback = 4;
	std::memcpy(buffer + (4 - n_putback), gptr() - n_putback, n_putback);

	// ERROR or EOF
	int num = gzread(file, buffer+4, bufferSize-4);
	if (num <= 0)
	  return EOF;

	// Reset buffer pointers
	setg(buffer + (4 - n_putback),   // Beginning of putback area
	     buffer + 4,                 // Read position
	     buffer + 4 + num);          // End of buffer

	// Return next character
	return *reinterpret_cast<unsigned char*>(gptr());    
      }

      /// Sync
      virtual int sync() {
	// Changed to use flush_buffer() instead of overflow(EOF)
	// which caused improper behavior with std::endl and flush(),
	// bug reported by Vincent Ricard.
	if (pptr() and pptr() > pbase()) {
	  if (flush_buffer() == EOF)
            return -1;
	}
	return 0;
      }
    };
    

    /// Zlib Stream Base
    class gzstreambase :
      virtual public std::ios {
    protected:
      /// Stream buffer
      gzstreambuf buf;

    public:
      /// Empty Constructor
      gzstreambase() {
	// Initialize
	init(&buf);
      }

      /// Constructor
      gzstreambase(const char* name, int open_mode) {
	init(&buf);
	open(name, mode);
      }

      /// Destructor
      ~gzstreambase() {
	buf.close();
      }

      /// Open
      void open(const char* name, int open_mode) {
	if (not buf.open(name, open_mode))
	  clear(rdstate() | std::ios::badbit);

      }

      /// Close
      void close() {
	if (buf.is_open())
	  if (not buf.close())
            clear(rdstate() | std::ios::badbit);
      }

      /// Buffer
      gzstreambuf* rdbuf() {
	return &buf;
      }
    };


    /// Input Zlib Stream
    class igzstream :
      public gzstreambase, public std::istream {
    public:
      /// Empty Constructor
      igzstream() :
	std::istream(&buf) {
      }

      /// Constructor
      igzstream(const char* name, int open_mode = std::ios::in) :
	gzstreambase(name, open_mode), std::istream(&buf) {
      }

      /// Buffer
      gzstreambuf* rdbuf() {
	return gzstreambase::rdbuf();
      }

      /// Open
      void open(const char* name, int open_mode = std::ios::in) {
        gzstreambase::open(name, open_mode);
      }
    };


    //// Output Zlib Stream
    class ogzstream :
      public gzstreambase, public std::ostream {
    public:
      /// Empty Constructor
      ogzstream() :
	std::ostream(&buf) {
      }

      /// Constructor
      ogzstream(const char* name, int mode = std::ios::out)
        : gzstreambase(name, mode), std::ostream(&buf) {
      }

      /// Buffer
      gzstreambuf* rdbuf() {
	return gzstreambase::rdbuf();
      }

      /// Open
      void open(const char* name, int open_mode = std::ios::out) {
        gzstreambase::open(name, open_mode);
      }
    };
  }
}

#endif
