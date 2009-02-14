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
      int flush_buffer() {
	// Separate the writing of the buffer from overflow() and
	// sync() operation.
	int w = pptr() - pbase();
	if (gzwrite(file_, pbase(), w) != w)
	  return EOF;
	pbump(-w);
	return w;
      }

    public:
      /// Constructor
      gzstreambuf() :
	opened_(0) {
        setp(buffer_, buffer_ + (bufferSize-1));
        setg(buffer_ + 4,     // Beginning of putback area
             buffer_ + 4,     // Read position
             buffer_ + 4);    // End position      
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
      gzstreambuf* open(const char* _name, int _open_mode) {
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
	file_ = gzopen(_name, fmode);
	if (file_ == 0)
	  return 0;
	opened_ = 1;

	// Return this
	return this;
      }

      /// Close
      gzstreambuf* close() {
	// Sync and close
	if (is_open()) {
	  sync();
	  opened_ = 0;
	  if (gzclose(file_) == Z_OK)
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
	int num = gzread(file_, buffer_+4, bufferSize-4);
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
    

    /// Zlib Stream Base
    class gzstreambase :
      virtual public std::ios {
    protected:
      /// Stream buffer
      gzstreambuf buf_;

    public:
      /// Empty Constructor
      gzstreambase() {
	// Initialize
	init(&buf_);
      }

      /// Constructor
      gzstreambase(const char* _name, int _open_mode) {
	init(&buf_);
	open(_name, _open_mode);
      }

      /// Destructor
      ~gzstreambase() {
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
      gzstreambuf* rdbuf() {
	return &buf_;
      }
    };


    /// Input Zlib Stream
    class igzstream :
      public gzstreambase, public std::istream {
    public:
      /// Empty Constructor
      igzstream() :
	std::istream(&buf_) {
      }

      /// Constructor
      igzstream(const char* _name, int _open_mode = std::ios::in) :
	gzstreambase(_name, _open_mode), std::istream(&buf_) {
      }

      /// Buffer
      gzstreambuf* rdbuf() {
	return gzstreambase::rdbuf();
      }

      /// Open
      void open(const char* _name, int _open_mode = std::ios::in) {
        gzstreambase::open(_name, _open_mode);
      }
    };


    //// Output Zlib Stream
    class ogzstream :
      public gzstreambase, public std::ostream {
    public:
      /// Empty Constructor
      ogzstream() :
	std::ostream(&buf_) {
      }

      /// Constructor
      ogzstream(const char* _name, int _open_mode = std::ios::out)
        : gzstreambase(_name, _open_mode), std::ostream(&buf_) {
      }

      /// Buffer
      gzstreambuf* rdbuf() {
	return gzstreambase::rdbuf();
      }

      /// Open
      void open(const char* _name, int _open_mode = std::ios::out) {
        gzstreambase::open(_name, _open_mode);
      }
    };
  }
}

#endif
