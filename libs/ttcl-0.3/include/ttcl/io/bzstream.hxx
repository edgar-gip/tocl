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
      int flush_buffer() {
	// Separate the writing of the buffer from overflow() and
	// sync() operation.
	int w = pptr() - pbase();
	if (BZ2_bzwrite(file_, pbase(), w) != w)
	  return EOF;
	pbump(-w);
	return w;
      }

    public:
      /// Constructor
      bzstreambuf() :
	opened_(0) {
        setp(buffer_, buffer_ + (bufferSize-1));
        setg(buffer_ + 4,     // Beginning of putback area
             buffer_ + 4,     // Read position
             buffer_ + 4);    // End position      
      }

      /// Destructor
      ~bzstreambuf() {
	close();
      }

      /// Is it open?
      int is_open() const {
	return opened_;
      }

      /// Open
      bzstreambuf* open(const char* _name, int _open_mode) {
	// Not open before
	if (is_open())
	  return 0;

	// No append nor read/write mode
	mode_ = _open_mode;
	if ((mode_ & std::ios::ate) or (mode_ & std::ios::app)
	    or ((mode_ & std::ios::in) and (mode_ & std::ios::out)))
	  return 0;

	// Open
	char  fmode[10];
	char* fmodeptr = fmode;
	if (mode_ & std::ios::in)
	  *fmodeptr++ = 'r';
	else if (mode_ & std::ios::out)
	  *fmodeptr++ = 'w';
	*fmodeptr++ = 'b';
	*fmodeptr = '\0';
	file_ = BZ2_bzopen(_name, fmode);
	if (file_ == 0)
	  return 0;
	opened_ = 1;

	// Return this
	return this;
      }

      /// Close
      bzstreambuf* close() {
	// Sync and close
	if (is_open()) {
	  sync();
	  opened_ = 0;
	  BZ2_bzclose(file_);
	  return this;
	}

	// Return null
	return 0;
      }

      /// Overflow
      /** Used for output buffer only
       */
      virtual int overflow(int c = EOF) {
	if (not (mode_ & std::ios::out) or not opened_)
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
	if (not (mode_ & std::ios::in) or not opened_)
	  return EOF;

	// Josuttis' implementation of inbuf
	int n_putback = gptr() - eback();
	if (n_putback > 4)
	  n_putback = 4;
	std::memcpy(buffer_ + (4 - n_putback), gptr() - n_putback, n_putback);

	// ERROR or EOF
	int num = BZ2_bzread(file_, buffer_+4, bufferSize-4);
	if (num <= 0)
	  return EOF;

	// Reset buffer pointers
	setg(buffer_ + (4 - n_putback),   // Beginning of putback area
	     buffer_ + 4,                 // Read position
	     buffer_ + 4 + num);          // End of buffer

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
    

    /// Bzlib Stream Base
    class bzstreambase :
      virtual public std::ios {
    protected:
      /// Stream buffer
      bzstreambuf buf_;

    public:
      /// Empty Constructor
      bzstreambase() {
	// Initialize
	init(&buf_);
      }

      /// Constructor
      bzstreambase(const char* _name, int _open_mode) {
	init(&buf_);
	open(_name, _open_mode);
      }

      /// Destructor
      ~bzstreambase() {
	buf_.close();
      }

      /// Is it open?
      int is_open() const {
	return buf_.is_open();
      }

      /// Open
      void open(const char* _name, int _open_mode) {
	if (not buf_.open(_name, _open_mode))
	  clear(rdstate() | std::ios::badbit);
      }

      /// Close
      void close() {
	if (buf_.is_open())
	  if (not buf_.close())
            clear(rdstate() | std::ios::badbit);
      }

      /// Buffer
      bzstreambuf* rdbuf() {
	return &buf_;
      }
    };


    /// Input Bzlib Stream
    class ibzstream :
      public bzstreambase, public std::istream {
    public:
      /// Empty Constructor
      ibzstream() :
	std::istream(&buf_) {
      }

      /// Constructor
      ibzstream(const char* _name, int _open_mode = std::ios::in) :
	bzstreambase(_name, _open_mode), std::istream(&buf_) {
      }

      /// Buffer
      bzstreambuf* rdbuf() {
	return bzstreambase::rdbuf();
      }

      /// Open
      void open(const char* _name, int _open_mode = std::ios::in) {
        bzstreambase::open(_name, _open_mode);
      }
    };


    //// Output Bzlib Stream
    class obzstream :
      public bzstreambase, public std::ostream {
    public:
      /// Empty Constructor
      obzstream() :
	std::ostream(&buf_) {
      }

      /// Constructor
      obzstream(const char* _name, int _open_mode = std::ios::out)
        : bzstreambase(_name, _open_mode), std::ostream(&buf_) {
      }

      /// Buffer
      bzstreambuf* rdbuf() {
	return bzstreambase::rdbuf();
      }

      /// Open
      void open(const char* _name, int _open_mode = std::ios::out) {
        bzstreambase::open(_name, _open_mode);
      }
    };
  }
}

#endif
