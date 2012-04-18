#ifndef TTCL_EXCEPTION_HXX
#define TTCL_EXCEPTION_HXX

// TTCL: The Template Clustering Library

/** @file
    Exceptions
    @author Edgar Gonzalez i Pellicer
*/

#ifdef TTCL_EXCEPTION_BACKTRACE
# include <execinfo.h>
# ifdef TTCL_EXCEPTION_DEMANGLE
#  include <cxxabi.h>
# endif
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
# define TTCL_WHAT_SIZE 1024
#endif

#include <ttcl/global.hxx>
#include <ttcl/types.hxx>

/// TTCL Namespace
namespace ttcl {

  /// Exception
  class exception :
    public std::exception {
  protected:
    /// Description message
    std::string message_;

    /// Exception source file
    std::string file_;

    /// Exception source line number
    uint line_no_;

#ifdef TTCL_EXCEPTION_BACKTRACE
    /// Backtrace addresses
    void** addresses_;

    /// Backtrace function names
    char** functions_;

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
#ifdef TTCL_EXCEPTION_BACKTRACE
      message_(_message), file_(_file), line_no_(_line_no),
      addresses_(0), functions_(0) {
      // Get the backtrace
      get_backtrace();
#else
      message_(_message), file_(_file), line_no_(_line_no) {
#endif
    }

    /// Constructor from a boost::format
    /** @param _file    Exception source file
	@param _line_no Exception source line number
	@param _message Description message
    */
    exception(const std::string& _file, uint _line_no,
	      const boost::format& _message) :
#ifdef TTCL_EXCEPTION_BACKTRACE
      message_(_message.str()), file_(_file), line_no_(_line_no),
      addresses_(0), functions_(0) {
      // Get the backtrace
      get_backtrace();
    }
#else
      message_(_message.str()), file_(_file), line_no_(_line_no) {
    }
#endif

    /// Constructor from a char* and a variable argument list
    /** printf-style interpolation
     */
    exception(const std::string& _file, uint _line_no,
	      const char* _format, ...) TTCL_PRINTF_CHECK(4, 5) :
#ifdef TTCL_EXCEPTION_BACKTRACE
      message_(), file_(_file), line_no_(_line_no),
      addresses_(0), functions_(0) {
      // Get the backtrace
      get_backtrace();
#else
      message_(), file_(_file), line_no_(_line_no) {
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
#ifdef TTCL_EXCEPTION_BACKTRACE
      message_(), file_(_file), line_no_(_line_no),
      addresses_(0), functions_(0) {
      // Get the backtrace
      get_backtrace();
#else
      message_(), file_(_file), line_no_(_line_no) {
#endif
    }

#ifdef TTCL_EXCEPTION_BACKTRACE
    /// Get the backtrace
    void get_backtrace() {
      // Get the backtrace
      void* bt_buffer[20];
      n_filled_ = backtrace(bt_buffer, 20);

      // Split the first 2
      n_filled_ -= 2;

      // Allocate space for addresses
      addresses_ =
	reinterpret_cast<void**>(std::malloc(n_filled_ * sizeof(void*)));
      if (not addresses_)
	throw std::bad_alloc();

      // Copy them
      std::memcpy(addresses_, bt_buffer + 2, n_filled_ * sizeof(void*));

      // Convert to symbols
      functions_ = backtrace_symbols(addresses_, n_filled_);

      // Check for out of memory
      if (not functions_) {
	std::free(addresses_);
	throw std::bad_alloc();
      }

# ifdef TTCL_EXCEPTION_DEMANGLE
      // Demangle each
      for (int i = 0; i < n_filled_; ++i) {
	// Demangled name
	char* demangled = 0;

	// Find the '('
	char* start = strchr(functions_[i], '(');
	if (start) {
	  // Find the '+'
	  char* end = strchr(start, '+');
	  if (end) {
	    // Copy to a dmg_buffer
	    char dmg_buffer[1024];
	    std::strncpy(dmg_buffer, start + 1, end - start - 1);
	    dmg_buffer[end - start - 1] = '\0';

	    // Demangle
	    int status;
	    demangled = abi::__cxa_demangle(dmg_buffer, NULL, 0, &status);

	    // Error?
	    if (status)
	      demangled = strdup(dmg_buffer);
	  }
	}

	// Demangled found?
	if (demangled) {
	  // Replace
	  functions_[i] = demangled;
	}
	else {
	  // Just duplicate
	  functions_[i] = strdup(functions_[i]);
	}
      }
# endif
    }
#endif

    /// Fill printf-style
    void fill_printf(const char* _format, std::va_list _args) {
      // Buffer
      char pf_buffer[TTCL_WHAT_SIZE];

      // Print to the buffer
      std::vsnprintf(pf_buffer, TTCL_WHAT_SIZE, _format, _args);

      // Save the message
      message_ = pf_buffer;
    }

  public:
    /// Copy Constructor
    /** @param _other Source exception
     */
    exception(const exception& _other) :
      std::exception(_other), message_(_other.message_),
      file_(_other.file_), line_no_(_other.line_no_) {
#ifdef TTCL_EXCEPTION_BACKTRACE
      // How many filled?
      n_filled_ = _other.n_filled_;

      // Reserve memory for the addresses
      addresses_ =
	reinterpret_cast<void**>(std::malloc(n_filled_ * sizeof(void*)));
      if (not addresses_)
	throw std::bad_alloc();

      // Copy the addresses
      std::memcpy(addresses_, _other.addresses_, n_filled_ * sizeof(void*));

      // Reserve memory for the function names
      functions_    =
	reinterpret_cast<char**>(std::malloc(n_filled_ * sizeof(char*)));
      if (not functions_) {
	std::free(addresses_);
	throw std::bad_alloc();
      }

# ifdef TTCL_EXCEPTION_DEMANGLE
      // Duplicate each function name
      for (int i = 0; i < n_filled_; ++i)
	functions_[i] = strdup(_other.functions_[i]);
# else
      // Copy the function names
      std::memcpy(functions_, _other.functions_, n_filled_ * sizeof(char*));
# endif
#endif
    }

    /// Destructor
    virtual ~exception() throw () {
#ifdef TTCL_EXCEPTION_BACKTRACE
# ifdef TTCL_EXCEPTION_DEMANGLE
      // Free each demangled name
      for (uint i = 0; i < n_filled_; ++i)
	std::free(functions_[i]);
# endif

      // Free the trace arrays
      std::free(addresses_);
      std::free(functions_);
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
    virtual void display(std::ostream& _os = std::cerr) const {
      _os << message_ << " in " << file_
	  << ":" << line_no_ << std::endl;

#ifdef TTCL_EXCEPTION_BACKTRACE
      for (int i = 0; i < n_filled_; ++i)
	_os << " from " << functions_[i] << " ["
	    << addresses_[i] << ']' << std::endl;
#endif
    }

    /// Description
    virtual const char* what() const
      throw() {
      static char buffer[TTCL_WHAT_SIZE];
#ifdef TTCL_EXCEPTION_BACKTRACE
      int printed =
#endif
	snprintf(buffer, TTCL_WHAT_SIZE - 1, "%s in %s:%d",
		 message_.c_str(), file_.c_str(), line_no_);

#ifdef TTCL_EXCEPTION_BACKTRACE
      int i = 0;
      while (printed < TTCL_WHAT_SIZE - 1 and
	     i < n_filled_) {
	printed += snprintf(buffer + printed, TTCL_WHAT_SIZE - printed,
			    " from %s [%p]", functions_[i], addresses_[i]);
	++i;
      }
#endif

      return buffer;
    }
  };
}

/// Throw an exception
#define TTCL_FIRE(...)						\
  throw ttcl::exception(__FILE__, __LINE__, __VA_ARGS__)

/// TODO
#define TTCL_TODO						\
  TTCL_FIRE("%s not implemented", __PRETTY_FUNCTION__)

/// Virtual
#define TTCL_PSEUDOVIRTUAL						\
  TTCL_FIRE("%s pseudovirtual version called", __PRETTY_FUNCTION__)

#endif

