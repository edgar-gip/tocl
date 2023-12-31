// Copyright (C) 2010 Edgar Gonzàlez i Pellicer <edgar.gip@gmail.com>
//
// This file is part of octopus-0.1.
//
// octopus is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the
// Free Software Foundation; either version 3 of the License, or (at your
// option) any later version.
//
// octopus is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for more details.
//
// You should have received a copy of the GNU General Public License
// along with octopus; see the file COPYING.  If not, see
// <http://www.gnu.org/licenses/>.

#ifndef OCTAVE_C_PTR_VALUE_HH
#define OCTAVE_C_PTR_VALUE_HH

#include <string>

#include <boost/shared_ptr.hpp>

#include <octave/oct.h>


/// Octave C Pointer Value
/** Owned by Octave, this means the object will be destroyed when no
    longer referenced by the script

    Adapted from octave_swig_ref, generated by SWIG
*/
template <typename T>
class octave_c_pointer_value : public octave_base_value {
private:
  /// Pointer to the data
  boost::shared_ptr<T> data_;

public:
  /// Constructor
  octave_c_pointer_value(T* _ptr = 0) :
    data_(_ptr) {
  }

  /// Copy constructor
  /** Copy reference semantics (that's what shared_ptr's are for)
   */
  octave_c_pointer_value(const octave_c_pointer_value& _other) :
    data_(_other.data_) {
  }

  /// Destructor
  ~octave_c_pointer_value() {
  }

  /// Get the data
  T& data() const {
    return *data_;
  }

  /// Clone
  virtual octave_c_pointer_value* clone() const {
    return new octave_c_pointer_value(*this);
  }

  /// Empty clone
  virtual octave_c_pointer_value* empty_clone() const {
    return new octave_c_pointer_value();
  }

  /// Is it defined?
  virtual bool is_defined() const {
    return data_.get();
  }

  /// Print
  virtual void print(std::ostream& _os, bool _read_syntax = false) const {
    _os << "Pointer(" << t_name << ':' << data_.get() << ')';
  }

private:
  DECLARE_OCTAVE_ALLOCATOR;
  DECLARE_OV_TYPEID_FUNCTIONS_AND_DATA;
};

/// Templated DEFINE_OCTAVE_ALLOCATOR
/** Adapted from <octave/oct-alloc.h>
 */
#define DEFINE_TEMPLATED_OCTAVE_ALLOCATOR(t)    \
  template <> octave_allocator t::allocator (sizeof (t))

/// Templated DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA
/** Adapted from <octave/ov-base.h>
 */
#define DEFINE_TEMPLATED_OV_TYPEID_FUNCTIONS_AND_DATA(t, n, c)          \
  template <> int t::t_id (-1);                                         \
  template <> const std::string t::t_name (n);                          \
  template <> const std::string t::c_name (c);                          \
  template <> void t::register_type()   {                               \
    t_id = octave_value_typeinfo::register_type (t::t_name,             \
                                                 t::c_name,             \
                                                 octave_value (new t ())); \
  }

/// Octave C Pointer Definitions
#define octave_c_pointer_static(T, typeName)                            \
  DEFINE_TEMPLATED_OCTAVE_ALLOCATOR(octave_c_pointer_value<T>);         \
  DEFINE_TEMPLATED_OV_TYPEID_FUNCTIONS_AND_DATA(octave_c_pointer_value<T>, \
                                                typeName, typeName);

#endif
