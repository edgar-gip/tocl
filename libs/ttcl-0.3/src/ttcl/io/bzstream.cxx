#include <ttcl/io/bzstream.hxx>

#include <bzlib.h>

#include <cstring>
#include <iostream>
#include <fstream>

using namespace std;
using namespace ttcl;
using namespace ttcl::io;


// Bzlib Stream Buffer

/// Flush buffer
int bzstreambuf::
flush_buffer() {
	// Separate the writing of the buffer from overflow() and
	// sync() operation.
	int w = pptr() - pbase();
	if (BZ2_bzwrite(file_, pbase(), w) != w)
	  return EOF;
	pbump(-w);
	return w;
      }

/// Constructor
bzstreambuf::
bzstreambuf() :
  opened_(0) {
  setp(buffer_, buffer_ + (bufferSize-1));
  setg(buffer_ + 4,     // Beginning of putback area
       buffer_ + 4,     // Read position
       buffer_ + 4);    // End position
}

/// Destructor
bzstreambuf::
~bzstreambuf() {
  close();
}

/// Is it open?
int bzstreambuf::
is_open() const {
  return opened_;
}

/// Open
bzstreambuf* bzstreambuf::
open(const char* _name, int _open_mode) {
  // Not open before
  if (is_open())
    return 0;

  // No append nor read/write mode
  mode_ = _open_mode;
  if ((mode_ & ios::ate) or (mode_ & ios::app)
      or ((mode_ & ios::in) and (mode_ & ios::out)))
    return 0;

  // Open
  char  fmode[10];
  char* fmodeptr = fmode;
  if (mode_ & ios::in)
    *fmodeptr++ = 'r';
  else if (mode_ & ios::out)
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
bzstreambuf* bzstreambuf::
close() {
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
int bzstreambuf::
overflow(int c) {
  if (not (mode_ & ios::out) or not opened_)
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
int bzstreambuf::
underflow() {
  // Something in the buffer
  if (gptr() and gptr() < egptr())
    return *reinterpret_cast<unsigned char*>(gptr());

  // Check mode and opened
  if (not (mode_ & ios::in) or not opened_)
    return EOF;

  // Josuttis' implementation of inbuf
  int n_putback = gptr() - eback();
  if (n_putback > 4)
    n_putback = 4;
  memcpy(buffer_ + (4 - n_putback), gptr() - n_putback, n_putback);

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
int bzstreambuf::
sync() {
  // Changed to use flush_buffer() instead of overflow(EOF)
  // which caused improper behavior with std::endl and flush(),
  // bug reported by Vincent Ricard.
  if (pptr() and pptr() > pbase()) {
    if (flush_buffer() == EOF)
      return -1;
  }
  return 0;
}


// Bzlib Stream Base

/// Empty Constructor
bzstreambase::
bzstreambase() {
  // Initialize
  init(&buf_);
}

/// Constructor
bzstreambase::
bzstreambase(const char* _name, int _open_mode) {
  init(&buf_);
  open(_name, _open_mode);
}

/// Destructor
bzstreambase::
~bzstreambase() {
  buf_.close();
}

/// Is it open?
int bzstreambase::
is_open() const {
  return buf_.is_open();
}

/// Open
void bzstreambase::
open(const char* _name, int _open_mode) {
  if (not buf_.open(_name, _open_mode))
    clear(rdstate() | ios::badbit);
}

/// Close
void bzstreambase::
close() {
  if (buf_.is_open())
    if (not buf_.close())
      clear(rdstate() | ios::badbit);
}

/// Buffer
bzstreambuf* bzstreambase::
rdbuf() {
  return &buf_;
}


// Input Bzlib Stream

/// Empty Constructor
ibzstream::
ibzstream() :
  istream(&buf_) {
}

/// Constructor
ibzstream::
ibzstream(const char* _name, int _open_mode) :
  bzstreambase(_name, _open_mode), istream(&buf_) {
}

/// Buffer
bzstreambuf* ibzstream::
rdbuf() {
  return bzstreambase::rdbuf();
}

/// Open
void ibzstream::
open(const char* _name, int _open_mode) {
  bzstreambase::open(_name, _open_mode);
}


// Output Bzlib Stream

/// Empty Constructor
obzstream::
obzstream() :
  ostream(&buf_) {
}

/// Constructor
obzstream::
obzstream(const char* _name, int _open_mode) :
  bzstreambase(_name, _open_mode), ostream(&buf_) {
}

/// Buffer
bzstreambuf* obzstream::
rdbuf() {
  return bzstreambase::rdbuf();
}

/// Open
void obzstream::
open(const char* _name, int _open_mode) {
  bzstreambase::open(_name, _open_mode);
}
