#ifndef TTCL_EXCEPTION_HXX
#define TTCL_EXCEPTION_HXX

// TTCL: The Template Clustering Library

/** @file
    Exceptions
    @author Edgar Gonzalez i Pellicer
*/

#include <cstdarg>
#include <exception>
#include <iostream>
#include <string>

#include <ttcl/global.hxx>
#include <ttcl/types.hxx>

#ifndef TTCL_EXCEPTION_WHAT_SIZE
# define TTCL_EXCEPTION_WHAT_SIZE 1024
#endif

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
              const std::string& _message);

    /// Constructor from a char* and a variable argument list
    /** printf-style interpolation
     */
    exception(const std::string& _file, uint _line_no,
              const char* _format, ...) TTCL_PRINTF_CHECK(4, 5);

  protected:
    /// Non-message specifying constructor
    exception(const std::string& _file, uint _line_no);

#ifdef TTCL_EXCEPTION_BACKTRACE
    /// Get the backtrace
    void
    get_backtrace();
#endif

    /// Fill printf-style
    void
    fill_printf(const char* _format, std::va_list _args);

  public:
    /// Copy Constructor
    /** @param _other Source exception
     */
    exception(const exception& _other);

    /// Destructor
    virtual
    ~exception() throw ();

    /// Get the message
    /** As a string
     */
    const std::string&
    message() const;

    /// Get the message
    /** As a char*
     */
    const char*
    c_message() const;

    /// Get the file
    /** As a string
     */
    const std::string&
    file() const;

    /// Get the file
    /** As a char*
     */
    const char*
    c_file() const;

    /// Get the line number
    uint
    line_no() const;

    /// Write to an ostream
    /** @param _os Target ostream
     */
    virtual void
    display(std::ostream& _os = std::cerr) const;

    /// Description
    virtual const char* what() const
      throw();
  };
}

/// Throw an exception
#define TTCL_FIRE(...)                                          \
  throw ttcl::exception(__FILE__, __LINE__, __VA_ARGS__)

/// TODO
#define TTCL_TODO                                               \
  TTCL_FIRE("%s not implemented", __PRETTY_FUNCTION__)

/// Virtual
#define TTCL_PSEUDOVIRTUAL                                              \
  TTCL_FIRE("%s pseudovirtual version called", __PRETTY_FUNCTION__)

#endif
