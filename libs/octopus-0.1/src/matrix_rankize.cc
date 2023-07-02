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

#include <algorithm>
#include <exception>
#include <string>
#include <utility>
#include <vector>

#include <octave/oct.h>


/********************/
/* Rankize a matrix */
/********************/

DEFUN_DLD(matrix_rankize, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[ @var{matrix} ] =}\
 matrix_rankize(@var{matrix}, [@var{dimension}], [@var{mode}])\n\
\n\
Rankize a matrix\n\
@end deftypefn") {
  // Result
  octave_value_list result;

  try {
    // Check the number of parameters
    if (args.length() < 1 or args.length() > 3 or nargout > 1)
      throw (const char*)0;

    // Check first argument
    if (not args(0).is_real_matrix())
      throw "matrix should be a real matrix";
    Matrix m = args(0).matrix_value();

    // Column-wisity
    bool column_wise;
    if (args.length() == 1) {
      // Is it a row vector?
      if (m.rows() == 1)
        // Work row-wise
        column_wise = false;
      else
        // Work column-wise
        column_wise = true;
    }
    else { // args.length() > 2
      // Check second argument
      if (not args(1).is_real_scalar())
        throw "dimension should be a real scalar";

      // Which dimension?
      int dim = args(1).int_value();
      if (dim != 1 and dim != 2)
        throw "dimension should be 1 or 2";

      // Column-wisity
      column_wise = (dim == 1);
    }

    // Mode
    bool ascending = true;
    if (args.length() == 3) {
      // Check third argument
      if (not args(2).is_string())
        throw "mode should be a string";
      std::string mode = args(2).string_value();

      // Check mode values
      if (mode != "ascend" and mode != "descend")
        throw "mode should be 'ascend' or 'descend'";

      // Mode
      ascending = mode == "ascend";
    }

    // Output
    Matrix out(m.rows(), m.columns());

    // Column or row-wise?
    if (column_wise) {
      // Column-wise
      for (int c = 0; c < m.columns(); ++c) {
        // Prepare the column
        std::vector< std::pair<double, int> > column;
        column.reserve(m.rows());
        for (int r = 0; r < m.rows(); ++r)
          column.push_back(std::make_pair(m(r, c), r));

        // Sort it
        if (ascending)
          std::sort(column.begin(), column.end());
        else
          std::sort(column.begin(), column.end(),
                    std::greater< std::pair<double, int> >());

        // Now, fill the ranks
        int r = 0;
        while (r < m.rows()) {
          // Find the end of the rank
          int re = r + 1;
          while (re < m.rows() and column[re].first == column[r].first)
            ++re;

          // Find it
          double rank = 1.0 + double(r + (re - 1)) / 2.0;

          // Set it
          for (int rk = r; rk  < re; ++rk)
            out(column[rk].second, c) = rank;

          // Next
          r = re;
        }
      }
    }
    else {
      // Row-wise
      for (int r = 0; r < m.rows(); ++r) {
        // Prepare the row
        std::vector< std::pair<double, int> > row;
        row.reserve(m.columns());
        for (int c = 0; c < m.columns(); ++c)
          row.push_back(std::make_pair(m(r, c), c));

        // Sort it
        if (ascending)
          std::sort(row.begin(), row.end());
        else
          std::sort(row.begin(), row.end(),
                    std::greater< std::pair<double, int> >());

        // Now, fill the ranks
        int c = 0;
        while (c < m.columns()) {
          // Find the end of the rank
          int ce = c + 1;
          while (ce < m.columns() and row[ce].first == row[c].first)
            ++ce;

          // Find it
          double rank = 1.0 + double(c + (ce - 1)) / 2.0;

          // Set it
          for (int ck = c; ck < ce; ++ck)
            out(r, row[ck].second) = rank;

          // Next
          c = ce;
        }
      }
    }

    // Set
    result.resize(1);
    result(1) = out;
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
  return result;
}


/*********************/
/* Blockize a matrix */
/*********************/

// PKG_ADD: autoload('matrix_blockize', which('matrix_rankize'));

DEFUN_DLD(matrix_blockize, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[ @var{matrix} ] =}\
 matrix_blockize(@var{matrix}, @var{row_block), [@var{column_block}])\n\
\n\
Blockize a matrix\n\
@end deftypefn") {
  // Result
  octave_value_list result;

  try {
    // Check the number of parameters
    if (args.length() < 2 or args.length() > 3 or nargout > 1)
      throw (const char*)0;

    // Check first argument
    if (not args(0).is_real_matrix())
      throw "matrix should be a real matrix";
    Matrix m = args(0).matrix_value();

    // Check second argument
    if (not args(1).is_real_scalar())
      throw "row_block should be a real scalar";
    int row_block = args(1).int_value();

    // Is third argument given?
    int column_block;
    if (args.length() > 2) {
      // Check it
      if (not args(2).is_real_scalar())
        throw "column_block should be a real scalar if given";
      column_block = args(2).int_value();
    }
    else {
      // Set it to the same as row_block
      column_block = row_block;
    }

    // Output
    Matrix out(m.rows() * row_block, m.columns() * column_block);

    // Fill it
    double* m_ptr   =   m.fortran_vec();
    double* out_ptr = out.fortran_vec();

    // For each one in the input
    for (int c = 0; c < m.columns(); ++c, m_ptr += m.rows()) {
      for (int crep = 0; crep < column_block; ++crep) {
        double* m_col_ptr = m_ptr;
        for (int r = 0; r < m.rows(); ++r, ++m_col_ptr)
          for (int rrep = 0; rrep < row_block; ++rrep, ++out_ptr)
            *out_ptr = *m_col_ptr;
      }
    }

    // Set
    result.resize(1);
    result(0) = out;
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
  return result;
}


/*************************/
/* Eye blockize a matrix */
/*************************/

// PKG_ADD: autoload('matrix_eyeblockize', which('matrix_rankize'));

DEFUN_DLD(matrix_eyeblockize, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[ @var{matrix} ] =}\
 matrix_eyeblockize(@var{matrix}, @var{eye_block))\n\
\n\
Eye-Blockize a matrix\n\
@end deftypefn") {
  // Result
  octave_value_list result;

  try {
    // Check the number of parameters
    if (args.length() != 2 or nargout > 1)
      throw (const char*)0;

    // Check first argument
    if (not args(0).is_real_matrix())
      throw "matrix should be a real matrix";
    Matrix m = args(0).matrix_value();

    // Check second argument
    if (not args(1).is_real_scalar())
      throw "row_block should be a real scalar";
    int eye_block = args(1).int_value();

    // Output
    Matrix out(m.rows() * eye_block, m.columns() * eye_block, 0.0);

    // Fill it
    double* m_ptr   =   m.fortran_vec();
    double* out_ptr = out.fortran_vec();

    // For each one in the input
    for (int c = 0; c < m.columns(); ++c, m_ptr += m.rows()) {
      for (int crep = 0; crep < eye_block; ++crep) {
        double* m_col_ptr = m_ptr;
        for (int r = 0; r < m.rows(); ++r, ++m_col_ptr, out_ptr += eye_block)
          out_ptr[crep] = *m_col_ptr;
      }
    }

    // Set
    result.resize(1);
    result(0) = out;
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
  return result;
}
