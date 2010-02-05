#include <octave/oct.h>
#include <octave/oct-map.h>
#include <octave/version.h>

#if   defined(OCTAVE_USE_RESIZE_FILL)
#define RESIZE_AND_FILL resize_fill
#elif defined(OCTAVE_USE_RESIZE_AND_FILL)
#define RESIZE_AND_FILL resize_and_fill
#else
#error "Either OCTAVE_USE_RESIZE_AND_FILL or OCTAVE_USE_RESIZE_FILL\
        must be defined"
#endif

// Module-specific quadratic-programming function
octave_value_list
quadprog_spec(int _n_vars, int _n_ineq, int _n_eq,
	      Matrix& _H, ColumnVector& _f,
	      Matrix& _Aineq, ColumnVector& _bineq,
	      Matrix& _Aeq, ColumnVector& _beq,
	      ColumnVector& _lb, ColumnVector& _ub,
	      ColumnVector& _x, Octave_map& _opts);

// Solve quadratic programming problems
DEFUN_DLD(quadprog, args, /* nargout */,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[ @var{x}, @var{fval}, @var{exitflag} ] =} quadprog(@var{H}, @var{f}, @var{Aineq}, @var{bineq}, @var{Aeq}, @var{beq}, @var{lb}, @var{ub}, @var{x0}, @var{options})\n\
\n\
Solve quadratic programming problems\n\
@end deftypefn") {
  // Output
  octave_value_list output;

  try {
    // Check the number of parameters
    if (args.length() < 4 or args.length() > 10) {
      print_usage();
      throw false;
    }
  
    // Get H
    Matrix H;
    int n_vars;
    if (args(0).is_real_scalar()) {
      H.RESIZE_AND_FILL(1, 1, args(0).scalar_value());
      n_vars = 1;
    }
    else if (args(0).is_real_matrix()) {
      if (args(0).rows() != args(0).columns())
	throw "H should be a square matrix";
      H = args(0).matrix_value();
      n_vars = H.rows();
    }
    else {
      throw "H should be a square matrix";
    }

    // Get f
    ColumnVector f;
    if (args(1).is_real_scalar()) {
      if (n_vars != 1)
	throw "f should be a column vector with the same rows as H";
      f.RESIZE_AND_FILL(1, args(1).scalar_value());
    }
    else if (args(1).is_real_matrix()) {
      if (args(1).columns() != 1 or args(1).rows() != n_vars)
	throw "f should be a column vector with the same rows as H";
      f = args(1).column_vector_value();
    }
    else {
      throw "f should be a column vector with the same rows as H";
    }

    // Get Aineq
    Matrix Aineq;
    int n_ineq;
    if (args(2).is_zero_by_zero()) {
      n_ineq = 0;
    }
    else if (args(2).is_real_scalar()) {
      if (n_vars != 1)
	throw "Aineq should be a matrix with the same columns as H";
      Aineq.RESIZE_AND_FILL(1, 1, args(2).scalar_value());
      n_ineq = 1;
    }
    else if (args(2).is_real_matrix()) {
      if (args(2).columns() != n_vars)
	throw "Aineq should be a matrix with the same columns as H";
      Aineq = args(2).matrix_value();
      n_ineq = Aineq.rows();
    }
    else {
      throw "Aineq should be a matrix with the same columns as H";
    }

    // Get bineq
    ColumnVector bineq;
    if (args(3).is_zero_by_zero()) {
      if (n_ineq != 0)
	throw "bineq should be a column vector with the same rows as Aineq";
    }
    else if (args(3).is_real_scalar()) {
      if (n_ineq != 1)
	throw "bineq should be a column vector with the same rows as Aineq";
      bineq.RESIZE_AND_FILL(1, args(3).scalar_value());
    }
    else if (args(3).is_real_matrix()) {
      if (args(3).columns() != 1 or args(3).rows() != n_ineq)
	throw "bineq should be a column vector with the same rows as Aineq";
      bineq = args(3).column_vector_value();
    }
    else {
      throw "bineq should be a column vector with the same rows as Aineq";
    }

    // Equality
    Matrix Aeq;
    int n_eq;
    ColumnVector beq;
  
    // Get Aeq
    if (args.length() <= 4 or args(4).is_zero_by_zero()) {
      n_eq = 0;
    }
    else if (args(4).is_real_scalar()) {
      if (n_vars != 1)
	throw "Aeq should be a matrix with the same columns as H";
      Aeq.RESIZE_AND_FILL(1, 1, args(4).scalar_value());
      n_eq = 1;
    }
    else if (args(4).is_real_matrix()) {
      if (args(4).columns() != n_vars)
	throw "Aeq should be a matrix with the same columns as H";
      Aeq = args(4).matrix_value();
      n_eq = Aeq.rows();
    }
    else {
      throw "Aeq should be a matrix with the same columns as H";
    }
    
    // Get beq
    if (args.length() <= 5 or args(5).is_zero_by_zero()) {
      if (n_eq != 0)
	throw "beq should be a column vector with the same rows as Aeq";
    }
    else if (args(5).is_real_scalar()) {
      if (n_eq != 1)
	throw "beq should be a column vector with the same rows as Aeq";
      beq.RESIZE_AND_FILL(1, args(5).scalar_value());
    }
    else if (args(5).is_real_matrix()) {
      if (args(5).columns() != 1 or args(5).rows() != n_eq)
	throw "beq should be a column vector with the same rows as Aeq";
      beq = args(5).column_vector_value();
    }
    else {
      throw "beq should be a column vector with the same rows as Aeq";
    }

    // Bounds
    ColumnVector lb;
    ColumnVector ub;

    // Get lb
    if (args.length() <= 6 or args(6).is_zero_by_zero()) {
      lb.RESIZE_AND_FILL(n_vars, -INFINITY);
    }
    else if (args(6).is_real_scalar()) {
      if (n_vars != 1)
	throw "lb should be a column vector with the same rows as H";
      lb.RESIZE_AND_FILL(n_vars, args(6).scalar_value());
    }
    else if (args(6).is_real_matrix()) {
      if (args(6).columns() != 1 or args(6).rows() != n_vars)
	throw "lb should be a column vector with the same rows as H";
      lb = args(6).column_vector_value();
    }
    else {
      throw "lb should be a column vector with the same rows as H";
    }

    // Get ub
    if (args.length() <= 7 or args(7).is_zero_by_zero()) {
      ub.RESIZE_AND_FILL(n_vars, INFINITY);
    }
    else if (args(7).is_real_scalar()) {
      if (n_vars != 1)
	throw "ub should be a column vector with the same rows as H";
      ub.RESIZE_AND_FILL(n_vars, args(7).scalar_value());
    }
    else if (args(7).is_real_matrix()) {
      if (args(7).columns() != 1 or args(7).rows() != n_vars)
	throw "ub should be a column vector with the same rows as H";
      ub = args(7).column_vector_value();
    }
    else {
      throw "ub should be a column vector with the same rows as H";
    }

    // Starting value
    ColumnVector x;

    // Get x0
    if (args.length() <= 8 or args(8).is_zero_by_zero()) {
      x.RESIZE_AND_FILL(n_vars, 0.0);
    }
    else if (args(8).is_real_scalar()) {
      if (n_vars != 1)
	throw "x0 should be a column vector with the same rows as H";
      x.RESIZE_AND_FILL(n_vars, args(8).scalar_value());
    }
    else if (args(8).is_real_matrix()) {
      if (args(8).columns() != 1 or args(8).rows() != n_vars)
	throw "x0 should be a column vector with the same rows as H";
      x = args(8).column_vector_value();
    }
    else {
      throw "x0 should be a column vector with the same rows as H";
    }

    // Options
    Octave_map opts;
    if (args.length() > 9) {
      if (args(9).is_map())
	opts = args(9).map_value();
      else
	throw "opts should be a struct";
    }

    // Call the specific version
    output = quadprog_spec(n_vars, n_ineq, n_eq,
			   H, f, Aineq, bineq, Aeq, beq,
			   lb, ub, x, opts);
  }
  catch (const char* _err) {
    // Show the error
    error(_err);
  }
  catch (...) {
    // Hum...
  }

  // Out
  return output;
}
