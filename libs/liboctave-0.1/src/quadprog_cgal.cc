#include <cmath>
#include <vector>

#include <octave/oct.h>
#include <octave/oct-map.h>

#include <CGAL/basic.h>
#include <CGAL/enum.h>
#include <CGAL/MP_Float.h>
#include <CGAL/QP_models.h>
#include <CGAL/QP_functions.h>

using namespace CGAL;

// Decompose a bound
static void decompose_bound(const ColumnVector& _v,
			    std::vector<bool>& _finiteness,
			    std::vector<double>& _value) {
  // Resize
  _finiteness.resize(_v.rows());
  _value     .resize(_v.rows());

  // For each
  for (int i = 0; i < _v.rows(); ++i) {
    if (std::isfinite(_v(i))) {
      _finiteness[i] = true;
      _value     [i] = _v(i);
    }
    else  {
      _finiteness[i] = false;
    }
  }
}

// Index a matrix
static const double** indexMatrix(const Matrix& _m) {
  const double*  data  = _m.data();
  const double** index = new const double*[_m.columns()];
  for (int c = 0; c < _m.columns(); ++c) {
    index[c] = data;
    data    += _m.rows();
  }
  return index;
}
  
// Module-specific quadratic-programming function
octave_value_list
quadprog_spec(int _n_vars, int _n_ineq, int _n_eq,
	      Matrix& _H, ColumnVector& _f,
	      Matrix& _Aineq, ColumnVector& _bineq,
	      Matrix& _Aeq, ColumnVector& _beq,
	      ColumnVector& _lb, ColumnVector& _ub,
	      ColumnVector& /* _x */, Octave_map& _opts) {
  // Bounds
  std::vector<bool>   lb_finiteness;
  std::vector<double> lb_value;
  std::vector<bool>   ub_finiteness;
  std::vector<double> ub_value;

  // Decompose bounds
  decompose_bound(_lb, lb_finiteness, lb_value);
  decompose_bound(_ub, ub_finiteness, ub_value);

  // Join ineq and eq
  Matrix A(_n_ineq + _n_eq, _n_vars);
  A.insert(_Aineq, 0,       0);
  A.insert(_Aeq,   _n_ineq, 0);
  ColumnVector b(_n_ineq + _n_eq);
  b.insert(_bineq, 0);
  b.insert(_beq,   _n_ineq);
  std::vector<Comparison_result> R(_n_ineq, SMALLER);
  R.resize(_n_ineq + _n_eq, EQUAL);

  // Is it linear?
  bool is_linear;
  if (_opts.seek("linear") != _opts.end()) {
    // Read the option
    is_linear = _opts.contents("linear")(0).bool_value();
  }
  else {
    // Check
    is_linear = true;
    for (int i = 0; is_linear and i < _n_vars; ++i)
      for (int j = 0; is_linear and j < _n_vars; ++j)
	is_linear = A(i, j) == 0.0;
  }

  // Is it nonnegative?
  bool is_nonnegative;
  if (_opts.seek("nonnegative") != _opts.end()) {
    // Read the option
    is_linear = _opts.contents("nonnegative")(0).bool_value();
  }
  else {
    // Check
    is_nonnegative = true;
    for (int i = 0; is_nonnegative and i < _n_vars; ++i)
      is_nonnegative = (lb_finiteness[i] and lb_value[i] == 0.0 and
			not ub_finiteness[i]);
  }

  // Solve the problem
  Quadratic_program_solution<MP_Float> solution;

  // Index A column-wise
  const double** A_index = indexMatrix(A);

  // Index H row-wise (if needed)
  Matrix TH;
  const double** H_index = 0;

  // Linearity/Quadraticity?
  if (is_linear) {

    // Nonnegativity/Generality?
    if (is_nonnegative) {
      // Linear nonnegative
      solution = solve_nonnegative_linear_program
	(make_nonnegative_linear_program_from_iterators
	 (_n_vars,
	  _n_ineq + _n_eq,
	  A_index,
	  b.data(),
	  &R.front(),
	  _f.data()),
	 MP_Float());
    }
    else {
      // Linear general
      solution = solve_linear_program
	(make_linear_program_from_iterators
	 (_n_vars,
	  _n_ineq + _n_eq,
	  A_index,
	  b.data(),
	  &R.front(),
	  lb_finiteness.begin(),
	  lb_value.begin(),
	  ub_finiteness.begin(),
	  ub_value.begin(),
	  _f.data()),
	 MP_Float());
    }
  }
  else {
    // Index H row-wise (or the transposed of H)
    TH      = _H.transpose();
    H_index = indexMatrix(TH);
    
    // Nonnegativity/Generality?
    if (is_nonnegative) {
      // Quadratic nonnegative
      solution = solve_nonnegative_quadratic_program
	(make_nonnegative_quadratic_program_from_iterators
	 (_n_vars,
	  _n_ineq + _n_eq,
	  A_index,
	  b.data(),
	  &R.front(),
	  H_index,
	  _f.data()),
	 MP_Float());
    }
    else {
      // Quadratic general
      solution = solve_quadratic_program
	(make_quadratic_program_from_iterators
	 (_n_vars,
	  _n_ineq + _n_eq,
	  A_index,
	  b.data(),
	  &R.front(),
	  lb_finiteness.begin(),
	  lb_value.begin(),
	  ub_finiteness.begin(),
	  ub_value.begin(),
	  H_index,
	  _f.data()),
	 MP_Float());
    }
  }
  
  // X
  ColumnVector x(_n_vars);
  int v = 0;
  for (Quadratic_program_solution<MP_Float>::Variable_value_iterator
	 it = solution.variable_values_begin();
       it != solution.variable_values_end(); ++it, ++v)
    x(v) = to_double(*it);

  // Objective function
  double fval = to_double(solution.objective_value());

  // Delete the indices
  delete[] A_index;
  delete[] H_index;

  // Return
  octave_value_list output;
  output.resize(3);
  output(0) = x;
  output(1) = fval;
  output(2) = true;
  return output;
}
