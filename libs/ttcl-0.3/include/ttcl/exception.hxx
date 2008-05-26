#ifndef _TTCL_EXCEPTION_HXX
#define _TTCL_EXCEPTION_HXX

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

#ifndef TTCL_NO_USE_BOOST
#include <boost/format.hpp>
#endif

#include <ttcl/types.hxx>

/// TTCL Namespace
namespace ttcl {

  /// Exception
  class exception : std::exception {
  private:
    /// Description message
    std::string _M_message;
    
    /// Exception source file
    std::string _M_file;
    
    /// Exception source line number
    uint _M_line_no;

#ifdef _EXECINFO_H    
    /// Backtrace
    char** _M_trace;
    
    /// Number of positions of trace filled
    int _M_n_filled;
#endif    

  public:
    /// Constructor
    /** @param _message Description message
	@param _file    Exception source file
	@param _line_no Exception source line number
    */
    exception(std::string _message, std::string _file, uint _line_no) :
      _M_message(_message), _M_file(_file), _M_line_no(_line_no) {
#ifdef _EXECINFO_H
      // Get the backtrace
      void* buffer[20];
      _M_n_filled = backtrace(buffer, 20);
      
      // Split the first 2
      _M_n_filled -= 2;
      
      // Convert to symbols
      _M_trace = backtrace_symbols(buffer + 2, _M_n_filled);

      // Check for out of memory
      if (not _M_trace)
	throw std::bad_alloc();
#endif
    }

#ifndef TTCL_NO_USE_BOOST
    /// Constructor from a boost::format
    /** Disabled if TTCL_NO_USE_BOOST is defined
	@param _message Description message
	@param _file    Exception source file
	@param _line_no Exception source line number
    */
    exception(boost::format _message, std::string _file, uint _line_no) :
      _M_message(_message.str()), _M_file(_file), _M_line_no(_line_no) {
#ifdef _EXECINFO_H
      // Get the backtrace
      void* buffer[20];
      _M_n_filled = backtrace(buffer, 20);
      
      // Split the first 2
      _M_n_filled -= 2;
      
      // Convert to symbols
      _M_trace = backtrace_symbols(buffer + 2, _M_n_filled);

      // Check for out of memory
      if (not _M_trace)
	throw std::bad_alloc();
#endif
    }
#endif

    /// Copy Constructor
    /** @param _other Source exception
     */
    exception(const exception& _other) :
      std::exception(_other), _M_message(_other._M_message),
      _M_file(_other._M_file), _M_line_no(_other._M_line_no) {
#ifdef _EXECINFO_H
      // Reserve memory for the trace
      _M_n_filled = _other._M_n_filled;
      _M_trace    =
	reinterpret_cast<char**>(std::malloc(_M_n_filled * sizeof(char*)));

      // Check for out of memory
      if (not _M_trace)
	throw std::bad_alloc();

      // Copy the trace
      std::memcpy(_M_trace, _other._M_trace, _M_n_filled * sizeof(char*));
#endif
    }

    /// Destructor
    ~exception() throw () {
#ifdef _EXECINFO_H
      std::free(_M_trace);
#endif
    }
    
    /// Write to an ostream
    /** @param _os Target ostream
     */
    void display(std::ostream& _os) const {
      _os << _M_message << " in " << _M_file << ":" << _M_line_no << std::endl;
#ifdef _EXECINFO_H
      for (int i = 0; i < _M_n_filled; ++i)
	_os << " from " << _M_trace[i] << std::endl;
#endif
    }
  };
}

/// Throw an exception
/** @param _message Description message
 */
#define ttcl_fire(_message)\
  throw ttcl::exception(_message, __FILE__, __LINE__)

#endif

