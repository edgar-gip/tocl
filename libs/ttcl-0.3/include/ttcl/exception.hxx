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

#include <cstdlib>
#include <cstring>
#include <exception>
#include <iostream>
#include <string>

#include <boost/format.hpp>

#ifndef TTCL_WHAT_SIZE
#define TTCL_WHAT_SIZE 1024
#endif

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
    /** @param _message Description message
	@param _file    Exception source file
	@param _line_no Exception source line number
    */
    exception(std::string _message, std::string _file, uint _line_no) :
      message_(_message), file_(_file), line_no_(_line_no) {
#ifdef _EXECINFO_H
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
#endif
    }

    /// Constructor from a boost::format
    /** @param _message Description message
	@param _file    Exception source file
	@param _line_no Exception source line number
    */
    exception(boost::format _message, std::string _file, uint _line_no) :
      message_(_message.str()), file_(_file), line_no_(_line_no) {
#ifdef _EXECINFO_H
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
#endif
    }

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
    const std::string& message() const {
      return message_;
    }

    /// Get the file
    const std::string& file() const {
      return file_;
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
/** @param _message Description message
 */
#define ttcl_fire(_message)\
  throw ttcl::exception(_message, __FILE__, __LINE__)

#endif

