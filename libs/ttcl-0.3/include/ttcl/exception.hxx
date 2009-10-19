#ifndef TTCL_EXCEPTION_HXX
#define TTCL_EXCEPTION_HXX

// TTCL: The Template Clustering Library

/** @file
    Exceptions
    @author Edgar Gonzalez i Pellicer
*/

#ifdef __linux__
#include <execinfo.h>
#endif

#include <cstdarg>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <exception>
#include <iostream>
#include <string>

#include <boost/format.hpp>

#ifndef TTCL_WHAT_SIZE
#define TTCL_WHAT_SIZE 1024
#endif

#include <ttcl/global.hxx>
#include <ttcl/types.hxx>

/// TTCL Namespace
namespace ttcl {

  /// Exception
  class exception : public std::exception {
  protected:
    /// Description message
    std::string message_;
    
    /// Exception source file
    std::string file_;
    
    /// Exception source line number
    uint line_no_;

#ifdef _EXECINFO_H    
    /// Backtrace
    char** trace_;
    
    /// Number of positions of trace filled
    int n_filled_;
#endif    

  public:
    /// Constructor
    /** @param _file    Exception source file
	@param _line_no Exception source line number
	@param _message Description message
    */
    exception(const std::string& _file, uint _line_no,
	      const std::string& _message) :
      message_(_message), file_(_file), line_no_(_line_no) {
#ifdef _EXECINFO_H
      // Get the backtrace
      get_backtrace();
#endif
    }

    /// Constructor from a boost::format
    /** @param _file    Exception source file
	@param _line_no Exception source line number
	@param _message Description message
    */
    exception(const std::string& _file, uint _line_no,
	      const boost::format& _message) :
      message_(_message.str()), file_(_file), line_no_(_line_no) {
#ifdef _EXECINFO_H
      // Get the backtrace
      get_backtrace();
#endif
    }

    /// Constructor from a char* and a variable argument list
    /** printf-style interpolation
     */
    exception(const std::string& _file, uint _line_no,
	      const char* _format, ...) ttcl_printf_check(4, 5) :
      message_(), file_(_file), line_no_(_line_no) {
#ifdef _EXECINFO_H
      // Get the backtrace
      get_backtrace();
#endif

      // Create the list
      std::va_list args;
      va_start(args, _format);

      // Call
      fill_printf(_format, args);

      // End
      va_end(args);
    }

  protected:
    /// Non-message specifying constructor
    exception(const std::string& _file, uint _line_no) :
      message_(), file_(_file), line_no_(_line_no) {
#ifdef _EXECINFO_H
      // Get the backtrace
      get_backtrace();
#endif
    }

#ifdef _EXECINFO_H
    /// Get the backtrace
    void get_backtrace() {
      // Get the backtrace
      void* buffer[20];
      n_filled_ = backtrace(buffer, 20);
      
      // Split the first 2
      n_filled_ -= 2;
      
      // Convert to symbols
      trace_ = backtrace_symbols(buffer + 2, n_filled_);

      // Check for out of memory
      if (not trace_)
	throw std::bad_alloc();
    }
#endif

    /// Fill printf-style
    void fill_printf(const char* _format, std::va_list _args) {
      // Buffer
      char buffer[TTCL_WHAT_SIZE];

      // Print to the buffer
      std::vsnprintf(buffer, TTCL_WHAT_SIZE, _format, _args);

      // Save the message
      message_ = buffer;
    }

  public:
    /// Copy Constructor
    /** @param _other Source exception
     */
    exception(const exception& _other) :
      std::exception(_other), message_(_other.message_),
      file_(_other.file_), line_no_(_other.line_no_) {
#ifdef _EXECINFO_H
      // Reserve memory for the trace
      n_filled_ = _other.n_filled_;
      trace_    =
	reinterpret_cast<char**>(std::malloc(n_filled_ * sizeof(char*)));

      // Check for out of memory
      if (not trace_)
	throw std::bad_alloc();

      // Copy the trace
      std::memcpy(trace_, _other.trace_, n_filled_ * sizeof(char*));
#endif
    }

    /// Destructor
    virtual ~exception() throw () {
#ifdef _EXECINFO_H
      std::free(trace_);
#endif
    }

    /// Get the message
    /** As a string
     */
    const std::string& message() const {
      return message_;
    }

    /// Get the message 
    /** As a char*
     */
    const char* c_message() const {
      return message_.c_str();
    }

    /// Get the file
    /** As a string
     */
    const std::string& file() const {
      return file_;
    }

    /// Get the file
    /** As a char*
     */
    const char* c_file() const {
      return file_.c_str();
    }

    /// Get the line number
    uint line_no() const {
      return line_no_;
    }

    /// Write to an ostream
    /** @param _os Target ostream
     */
    virtual void display(std::ostream& _os) const {
      _os << message_ << " in " << file_
	  << ":" << line_no_ << std::endl;
#ifdef _EXECINFO_H
      for (int i = 0; i < n_filled_; ++i)
	_os << " from " << trace_[i] << std::endl;
#endif
    }

    /// Description
    virtual const char* what() const
      throw() {
      static char buffer[TTCL_WHAT_SIZE];
      int printed = snprintf(buffer, TTCL_WHAT_SIZE - 1, "%s in %s:%d",
			     message_.c_str(), file_.c_str(), line_no_);
#ifdef _EXECINFO_H
      int i = 0;
      while (printed < TTCL_WHAT_SIZE - 1 and
	     i < n_filled_) {
	printed += snprintf(buffer + printed, TTCL_WHAT_SIZE - printed,
			    " from %s", trace_[i]);
	++i;
      }
#endif
      return buffer;
    }
  };
}

/// Throw an exception
#define ttcl_fire(...)						\
  throw ttcl::exception(__FILE__, __LINE__, __VA_ARGS__)

/// TODO
#define ttcl_todo\
  ttcl_fire("%s not implemented", __PRETTY_FUNCTION__);

/// Virtual
#define ttcl_pseudovirtual\
  ttcl_fire("%s pseudovirtual version called", __PRETTY_FUNCTION__);

#endif

