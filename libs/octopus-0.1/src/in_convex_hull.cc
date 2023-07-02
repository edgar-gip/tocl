// Copyright (C) 2011 Edgar Gonzàlez i Pellicer <edgar.gip@gmail.com>
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

#include <exception>
#include <iterator>

#include <boost/config.hpp>
#include <boost/iterator/transform_iterator.hpp>

#include <CGAL/MP_Float.h>
#include <CGAL/QP_models.h>
#include <CGAL/QP_functions.h>

#include <octave/oct.h>

// Homogeneous vector iterator
struct homogeneous_vector_iterator {
private:
  // Current data pointer
  const double* p_;

  // Stride
  octave_idx_type stride_;

public:
  // Empty constructor
  homogeneous_vector_iterator() :
    p_(0), stride_(0) {
  }

  // Constructor from a pointer and a stride
  homogeneous_vector_iterator(const double* _p, octave_idx_type _stride) :
    p_(_p), stride_(_stride) {
  }

  // Constructor from a matrix and a column
  homogeneous_vector_iterator(const Matrix& _m, octave_idx_type _column) :
    p_(_m.data() + _m.rows() * _column), stride_(_m.rows()) {
  }

  // Copy constructor
  homogeneous_vector_iterator(const homogeneous_vector_iterator& _other) :
    p_(_other.p_), stride_(_other.stride_) {
  }

  // Equality comparison
  bool operator==(const homogeneous_vector_iterator& _other) const {
    return p_ == _other.p_;
  }

  // Inequality comparison
  bool operator!=(const homogeneous_vector_iterator& _other) const {
    return p_ != _other.p_;
  }

  // Indirection
  double operator*() const {
    return stride_ ? *p_ : 1.0;
  }

  // Random access
  double operator[](int _index) const {
    return _index != stride_ ? p_[_index] : 1.0;
  }

  // Pre-increment
  homogeneous_vector_iterator& operator++() {
    ++p_;
    --stride_;
    return *this;
  }

  // Post-increment
  homogeneous_vector_iterator operator++(int) {
    homogeneous_vector_iterator ret(*this);
    ++(*this);
    return ret;
  }

  // Addition
  homogeneous_vector_iterator& operator+=(int _index) {
    p_      += _index;
    stride_ -= _index;
    return *this;
  }

  // Addition
  homogeneous_vector_iterator operator+(int _index) const {
    homogeneous_vector_iterator ret(*this);
    return (ret += _index);
  }

  // Pre-decrement
  homogeneous_vector_iterator& operator--() {
    --p_;
    ++stride_;
    return *this;
  }

  // Post-decrement
  homogeneous_vector_iterator operator--(int) {
    homogeneous_vector_iterator ret(*this);
    --(*this);
    return ret;
  }

  // Substraction
  homogeneous_vector_iterator& operator-=(int _index) {
    p_      -= _index;
    stride_ += _index;
    return *this;
  }

  // Substraction
  homogeneous_vector_iterator operator-(int _index) const {
    homogeneous_vector_iterator ret(*this);
    return (ret -= _index);
  }

  // Difference
  ptrdiff_t operator-(const homogeneous_vector_iterator& _other) const {
    return p_ - _other.p_;
  }
};

// Iterator traits
namespace std {
  template <>
  struct iterator_traits<homogeneous_vector_iterator> {
    typedef random_access_iterator_tag iterator_category;
    typedef double                     value_type;
    typedef ptrdiff_t                  difference_type;
    typedef double*                    pointer;
    typedef double&                    reference;
  };
}


// Homogeneous matrix iterator
struct homogeneous_matrix_iterator {
private:
  // Current data pointer
  const double* p_;

  // Stride
  octave_idx_type stride_;

public:
  // Empty constructor
  homogeneous_matrix_iterator() :
    p_(0), stride_(0) {
  }

  // Constructor from a matrix
  homogeneous_matrix_iterator(const Matrix& _m) :
    p_(_m.data()), stride_(_m.rows()) {
  }

  // Copy constructor
  homogeneous_matrix_iterator(const homogeneous_matrix_iterator& _other) :
    p_(_other.p_), stride_(_other.stride_) {
  }

  // Equality comparison
  bool operator==(const homogeneous_matrix_iterator& _other) const {
    return p_ == _other.p_;
  }

  // Inequality comparison
  bool operator!=(const homogeneous_matrix_iterator& _other) const {
    return p_ != _other.p_;
  }

  // Indirection
  homogeneous_vector_iterator operator*() const {
    return homogeneous_vector_iterator(p_, stride_);
  }

  // Random access
  homogeneous_vector_iterator operator[](int _index) const {
    return homogeneous_vector_iterator(p_ + stride_ * _index, stride_);
  }

  // Pre-increment
  homogeneous_matrix_iterator& operator++() {
    p_ += stride_;
    return *this;
  }

  // Post-increment
  homogeneous_matrix_iterator operator++(int) {
    homogeneous_matrix_iterator ret(*this);
    ++(*this);
    return ret;
  }

  // Addition
  homogeneous_matrix_iterator& operator+=(int _index) {
    p_ += _index * stride_;
    return *this;
  }

  // Addition
  homogeneous_matrix_iterator operator+(int _index) const {
    homogeneous_matrix_iterator ret(*this);
    return (ret += _index);
  }

  // Pre-decrement
  homogeneous_matrix_iterator& operator--() {
    p_ -= stride_;
    return *this;
  }

  // Post-decrement
  homogeneous_matrix_iterator operator--(int) {
    homogeneous_matrix_iterator ret(*this);
    --(*this);
    return ret;
  }

  // Substraction
  homogeneous_matrix_iterator& operator-=(int _index) {
    p_ -= _index * stride_;
    return *this;
  }

  // Substraction
  homogeneous_matrix_iterator operator-(int _index) const {
    homogeneous_matrix_iterator ret(*this);
    return (ret -= _index);
  }
};

// Iterator traits
namespace std {
  template <>
  struct iterator_traits<homogeneous_matrix_iterator> {
    typedef random_access_iterator_tag   iterator_category;
    typedef homogeneous_vector_iterator  value_type;
    typedef ptrdiff_t                    difference_type;
    typedef homogeneous_vector_iterator* pointer;
    typedef homogeneous_vector_iterator& reference;
  };
}


// In convex hull
static void in_convex_hull(const Matrix& _set,
                           const Matrix& _targets,
                           boolMatrix& _outcome) {
  // Relation type ("=")
  typedef CGAL::Const_oneset_iterator<CGAL::Comparison_result> R_it;

  // Linear objective function type (c = 0: we only test feasibility)
  typedef CGAL::Const_oneset_iterator<double> C_it;

  // Program type
  typedef CGAL::Nonnegative_linear_program_from_iterators
      <homogeneous_matrix_iterator, homogeneous_vector_iterator, R_it, C_it>
    Program;

  // Get the sizes
  octave_idx_type n_set     = _set.columns();
  octave_idx_type n_dims    = _set.rows(); // = _targets.rows();
  octave_idx_type n_targets = _targets.columns();

  // Set iterator
  homogeneous_matrix_iterator set_it(_set);

  // For each target
  for (octave_idx_type i = 0; i < n_targets; ++i) {
    // Target iterator
    homogeneous_vector_iterator target_it(_targets, i);

    // Create a program
    Program lp(n_set,      // Number of variables
               n_dims + 1, // Number of constraints
               set_it, target_it, R_it(CGAL::EQUAL), C_it(0.0));

    // Solve it
    CGAL::MP_Float dummy;
    CGAL::Quadratic_program_solution<CGAL::MP_Float> solution =
      CGAL::solve_nonnegative_linear_program(lp, dummy);

    // Is it feasible?
    _outcome(i) = not solution.is_infeasible();
  }
}


// Solve quadratic programming problems
DEFUN_DLD(in_convex_hull, _args, _nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[ @var{inside} ] =}\
 in_convex_hull(@var{set}, @var{target})\n      \
\n\
Determine if target points are inside the convex hull of set\n\
@end deftypefn") {
  // Output
  octave_value_list output;

  try {
    // Check the number of parameters
    if (_args.length() != 2 or _nargout > 1)
      throw (const char*)0;

    // Check set is a real matrix
    if (not (_args(0).is_matrix_type() and _args(0).is_real_type()))
      throw "set must be a real matrix";

    // Get set
    Matrix set = _args(0).matrix_value();

    // Check target is a real matrix
    if (not (_args(1).is_matrix_type() and _args(1).is_real_type()))
      throw "target must be a real matrix";

    // Get target
    Matrix target = _args(1).matrix_value();

    // Check rows are the same
    if (set.rows() != target.rows())
      throw "set and target must have the same number of columns";

    // Output
    boolMatrix outcome(1, target.columns());

    // Call
    in_convex_hull(set, target, outcome);

    // Return
    output.resize(1);
    output(0) = outcome;
  }
  // Was there an error?
  catch (const char* _error) {
    // Display the error or the usage
    if (_error)
      error(_error);
    else
      print_usage();
  }
  // Was there an exception
  catch (std::exception& _excep) {
    // Display the error
    error(_excep.what());
  }

  // Return the result
  return output;
}
