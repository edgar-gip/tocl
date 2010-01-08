#include <algorithm>
#include <vector>

#include <octave/oct.h>

#include <ttcl/ut/range.hxx>


/*******************************************/
/* Find the CPM3C most violated constraint */
/*******************************************/

DEFUN_DLD(CPM3C_mvc, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[ @var{constraint}, @var{violation}, @var{z}, @var{product} ] =} CPM3C_mvc(@var{data}, @var{omega})\n\
\n\
Find the CPM3C most violated constraint\n\
@end deftypefn") {
  // Check the number of parameters
  if (args.length() != 2 or nargout < 1 or nargout > 4) {
    print_usage();
    return octave_value_list();
  }
  
  // Check data
  if (not args(0).is_matrix_type()) { 
    error("data should be a matrix");
    return octave_value_list();
  }

  // Get omega
  if (not args(1).is_matrix_type()) { 
    error("omega should be a matrix");
    return octave_value_list();
  }
  Matrix omega = args(1).matrix_value();

  // Product
  Matrix product;

  // Get data
  if (args(0).is_sparse_type()) {
    // As a sparse matrix
    SparseMatrix data = args(0).sparse_matrix_value();

    // Check dimensions
    if (data.rows() != omega.rows()) {
      error("data and omega should have the same number of rows");
      return octave_value_list();
    }

    // Multiply
    product = omega.transpose() * data;
  }
  else {
    // As a dense matrix
    Matrix data = args(0).matrix_value();

    // Check dimensions
    if (data.rows() != omega.rows()) {
      error("data and omega should have the same number of rows");
      return octave_value_list();
    }

    // Multiply
    product = omega.transpose() * data;
  }

  // Violation
  double violation = 0.0;

  // Constraint sparse matrix rows and cols
  std::vector<octave_idx_type> constraint_rows;
  std::vector<octave_idx_type> constraint_cols;

  // z sparse matrix rows
  std::vector<octave_idx_type> z_rows;

  // Reserve
  int n_samples = product.columns();
  constraint_rows.reserve(n_samples);
  constraint_cols.reserve(n_samples);
  z_rows         .reserve(n_samples);

  // Now, for each sample, find the winner and the runner's up
  constraint_cols.push_back(0);
  for (int i = 0; i < n_samples; ++i) {
    // Starting winner and runner's up
    octave_idx_type win, rup;
    if (product(0, i) > product(1, i)) { win = 0; rup = 1; }
    else                               { win = 1; rup = 0; }

    // For the others
    for (int r = 2; r < product.rows(); ++r) {
      if      (product(r, i) > product(win, i)) { rup = win; win = r; }
      else if (product(r, i) > product(rup, i)) { rup = r; }
    }

    // Add the winer
    z_rows.push_back(win);

    // Is the margin not enough?
    if (product(win, i) - product(rup, i) < 1) {
      // Count violation
      violation += 1.0 - product(win, i) + product(rup, i);

      // Add a constraint
      constraint_rows.push_back(rup);
    }

    // Index column
    constraint_cols.push_back(constraint_rows.size());
  }

  // Normalize violation
  violation /= n_samples;

  // Prepare output
  octave_value_list output;
  output.resize(nargout);

  // Create a sparse matrix for constraint
  int n_sparse = constraint_rows.size();
  SparseMatrix constraint = SparseMatrix(product.rows(), n_samples, n_sparse);
  std::fill(constraint.data(), constraint.data() + n_sparse, 1.0);
  std::copy(constraint_rows.begin(), constraint_rows.end(), constraint.ridx());
  std::copy(constraint_cols.begin(), constraint_cols.end(), constraint.cidx());

  // Assign
  output(0) = constraint;

  // More output?
  if (nargout > 1) {
    // Violation
    output(1) = violation;

    // More output?
    if (nargout > 2) {
      // Create a sparse matrix for z
      SparseMatrix z = SparseMatrix(product.rows(), n_samples, n_samples);
      std::fill(z.data(), z.data() + n_samples, 1.0);
      std::copy(z_rows.begin(), z_rows.end(), z.ridx());
      std::copy(ttcl::ut::range(0), ttcl::ut::range(n_samples + 1), z.cidx());
      
      // Assign
      output(2) = z;

      // More output?
      if (nargout > 3) {
	// Assign the product
	output(3) = product;
      }
    }
  }

  // Return the output
  return output;
}


/***************************/
/* Find the CPM3C z matrix */
/***************************/

DEFUN_DLD(CPM3C_z, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{z} =} CPM3C_z(@var{data}, @var{omega})\n \
\n\
Find the CPM3C z matrix\n\
@end deftypefn") {
  // Check the number of parameters
  if (args.length() != 2 or nargout != 1) {
    print_usage();
    return octave_value_list();
  }
  
  // Check data
  if (not args(0).is_matrix_type()) { 
    error("data should be a matrix");
    return octave_value_list();
  }

  // Get omega
  if (not args(1).is_matrix_type()) { 
    error("omega should be a matrix");
    return octave_value_list();
  }
  Matrix omega = args(1).matrix_value();

  // Product
  Matrix product;

  // Get data
  if (args(0).is_sparse_type()) {
    // As a sparse matrix
    SparseMatrix data = args(0).sparse_matrix_value();

    // Check dimensions
    if (data.rows() != omega.rows()) {
      error("data and omega should have the same number of rows");
      return octave_value_list();
    }

    // Multiply
    product = omega.transpose() * data;
  }
  else {
    // As a dense matrix
    Matrix data = args(0).matrix_value();

    // Check dimensions
    if (data.rows() != omega.rows()) {
      error("data and omega should have the same number of rows");
      return octave_value_list();
    }

    // Multiply
    product = omega.transpose() * data;
  }

  // z sparse matrix rows
  std::vector<octave_idx_type> z_rows;

  // Reserve
  int n_samples = product.columns();
  z_rows.reserve(n_samples);

  // Now, for each sample, find the winner and the runner's up
  for (int i = 0; i < n_samples; ++i) {
    // Starting winner
    octave_idx_type win = 0;

    // For the others
    for (int r = 1; r < product.rows(); ++r)
      if (product(r, i) > product(win, i))
	win = r;

    // Add the winer
    z_rows.push_back(win);
  }

  // Prepare output
  octave_value_list output;
  output.resize(nargout);

  // Create a sparse matrix for z
  SparseMatrix z = SparseMatrix(product.rows(), n_samples, n_samples);
  std::fill(z.data(), z.data() + n_samples, 1.0);
  std::copy(z_rows.begin(), z_rows.end(), z.ridx());
  std::copy(ttcl::ut::range(0), ttcl::ut::range(n_samples + 1), z.cidx());
      
  // Assign
  output(0) = z;

  // Return the output
  return output;
}


/*****************************/
/* Find the CPM3C clustering */
/*****************************/

DEFUN_DLD(CPM3C_cluster, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{clustering} =} CPM3C_cluster(@var{data}, @var{omega})\n\
\n\
Find the CPM3C clustering\n\
@end deftypefn") {
  // Check the number of parameters
  if (args.length() != 2 or nargout != 1) {
    print_usage();
    return octave_value_list();
  }
  
  // Check data
  if (not args(0).is_matrix_type()) { 
    error("data should be a matrix");
    return octave_value_list();
  }

  // Get omega
  if (not args(1).is_matrix_type()) { 
    error("omega should be a matrix");
    return octave_value_list();
  }
  Matrix omega = args(1).matrix_value();

  // Product
  Matrix product;

  // Get data
  if (args(0).is_sparse_type()) {
    // As a sparse matrix
    SparseMatrix data = args(0).sparse_matrix_value();

    // Check dimensions
    if (data.rows() != omega.rows()) {
      error("data and omega should have the same number of rows");
      return octave_value_list();
    }

    // Multiply
    product = omega.transpose() * data;
  }
  else {
    // As a dense matrix
    Matrix data = args(0).matrix_value();

    // Check dimensions
    if (data.rows() != omega.rows()) {
      error("data and omega should have the same number of rows");
      return octave_value_list();
    }

    // Multiply
    product = omega.transpose() * data;
  }

  // Output
  int n_samples = product.columns();
  RowVector clustering(n_samples);

  // Now, for each sample, find the winner and the runner's up
  for (int i = 0; i < n_samples; ++i) {
    // Starting winner
    octave_idx_type win = 0;

    // For the others
    for (int r = 1; r < product.rows(); ++r)
      if (product(r, i) > product(win, i))
	win = r;

    // Set the winer
    clustering(i) = win;
  }

  // Prepare output
  octave_value_list output;
  output.resize(nargout);
  output(0) = clustering;

  // Return the output
  return output;
}
