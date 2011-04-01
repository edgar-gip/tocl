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
#include <cmath>
#include <exception>
// #include <iostream>
#include <vector>

#include <octave/oct.h>
#include <octave/oct-map.h>

#include "quadprog_common.h"


// Fortran qpgen2_ function
extern "C"
void qpgen2_(double* dmat, double* dvec, const int& fddmat, const int& n,
	     double* sol,  double* lagr, double& crval,
	     double* amat, double* bvec, const int& fdamat,
	     const int& q, const int& meq, int* iact, int& nact, int* iter,
	     double* work, int& ierr);

// Solve quadratic programming problems
DEFUN_DLD(quadprog_turlach, args, /* nargout */,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[ @var{x}, @var{fval}, @var{info} ] =}\
 quadprog_turlach(@var{H}, @var{f}, @var{Aineq}, @var{bineq}, @var{Aeq}, @var{beq},\
 @var{lb}, @var{ub}, @var{x0}, @var{options})\n	\
\n\
Solve quadratic programming problems using Berwin A. Turlach's implementation\n\
of the Goldfarb/Idnani algorithm.\n\
@end deftypefn") {
  // Output
  octave_value_list output;

  try {
    // Parse
    int _n_vars, _n_ineq, _n_eq;
    Matrix _H, _Aineq, _Aeq;
    ColumnVector _f, _bineq, _beq, _lb, _ub, _x;
    Octave_map _opts;
    parse_quadprog_args(args, _n_vars, _n_ineq,  _n_eq, _H, _f,
			_Aineq, _bineq, _Aeq, _beq, _lb, _ub,
			_x, _opts);

    // Make copies of required data
    Matrix       dmat =  _H;
    ColumnVector dvec = -_f;

    // Count effective lower and upper bounds
    int n_eff = 0;
    for (int i = 0; i < _n_vars; ++i) {
      if (std::isfinite(_lb(i))) ++n_eff;
      if (std::isfinite(_ub(i))) ++n_eff;
    }
	
    // Total number of constraints
    int n_constraints = _n_eq + _n_ineq + n_eff;

    // Joint constraint matrix
    Matrix amat(_n_vars, n_constraints, 0.0);
    amat.insert( _Aeq  .transpose(), 0,     0);
    amat.insert(-_Aineq.transpose(), 0, _n_eq);

    // Joint constraint vector
    ColumnVector bvec(n_constraints, 0.0);
    bvec.insert( _beq,   0);
    bvec.insert(-_bineq, _n_eq);

    // Add lower and upper bounds
    int c = _n_eq + _n_ineq;
    for (int i = 0; i < _n_vars; ++i) {
      if (std::isfinite(_lb(i))) {
	amat(i, c) = 1.0;
	bvec(c)    = _lb(i);
	++c;
      }
      if (std::isfinite(_ub(i))) {
	amat(i, c) = -1.0;
	bvec(c)    = -_ub(i);
	++c;
      }
    }

    // Error flag
    int ierr = 0; // 0 on input -> Must factor dmat

    // Outputs
    ColumnVector sol(_n_vars);
    ColumnVector lagr(n_constraints);
    double crval;
    std::vector<int> iact(n_constraints);
    int nact;
    int iter[2];
    
    // Working space
    int r     = std::min(_n_vars, n_constraints);
    int wsize = 2 * _n_vars + r * (r + 5) / 2 + 2 * n_constraints + 1;
    std::vector<double> work(wsize);

    /*
    // Display dmat
    std::cerr << "dmat = " << std::endl;
    for (uint r = 0; r < _n_vars; ++r) {
      for (uint c = 0; c < _n_vars; ++c)
	std::cerr  << ' ' << dmat(r, c);
      std::cerr << std::endl;
    }

    // Display dvec
    std::cerr << "dvec = " << std::endl;
    for (uint r = 0; r < _n_vars; ++r)
      std::cerr  << ' ' << dvec(r);
    std::cerr << std::endl;

    // Display amat and bvec
    std::cerr << "amat, bvec = " << std::endl;
    for (uint c = 0; c < n_constraints; ++c) {
      for (uint r = 0; r < _n_vars; ++r)
	std::cerr  << ' ' << amat(r, c);
      std::cerr << (c < _n_eq ? " = " : " >= ") << bvec(c) << std::endl;
    }
    */

    // Call!!
    qpgen2_(dmat.fortran_vec(), dvec.fortran_vec(), _n_vars, _n_vars, 
	    sol.fortran_vec(), lagr.fortran_vec(), crval,
	    amat.fortran_vec(), bvec.fortran_vec(), _n_vars,
	    n_constraints, _n_eq, &iact.front(), nact, iter,
	    &work.front(), ierr);

    // Extract the fields
    Octave_map info;
    switch (ierr) {
    case 0:
      info.assign("iterations", iter[0]);
      info.assign("status", "optimal");
      break;
    case 1:
      info.assign("status", "unbounded");
      crval = -INFINITY;
      break;
    case 2:
      info.assign("status", "non-decomposable");
      crval = NAN;
      break;
    }

    // Return
    output.resize(3);
    output(0) = sol;
    output(1) = crval;
    output(2) = info;
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
