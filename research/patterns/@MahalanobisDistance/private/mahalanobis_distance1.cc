#include <cmath>
#include <exception>
// #include <iostream>

#include <octave/oct.h>

// Helper function
template <typename SMatrix, typename TMatrix>
static void mahalanobis_distance(Matrix& _distances,
				 const Matrix& _S,
				 const SMatrix& _source,
				 const TMatrix& _target) {
  // Number of dimensions
  octave_idx_type n_dims = _source.rows(); // == _target.rows();

  // Number of source samples
  octave_idx_type n_src = _source.columns();

  // Number of target samples
  octave_idx_type n_tgt = _target.columns();

  // Resize distances
  _distances.resize(n_src, n_tgt, 0.0);

  // For each source
  for (octave_idx_type src = 0; src < n_src; ++src) {
    for (octave_idx_type tgt = 0; tgt < n_tgt; ++tgt) {
      // Difference
      ColumnVector diff = _source.column(src) - _target.column(tgt);

      // Mahalanobis distance is...
      _distances(src, tgt) = diff.transpose() * _S * diff;
    }
  }
}

// Octave callback
DEFUN_DLD(mahalanobis_distance1, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function}\
 {[ @var{dist} ] =} mahalanobis_distance1(@var{S}, @var{source})\n\
\n\
Find the mahalanobis distance between elements of @var{source}\n\
@end deftypefn") {
  // Result
  octave_value_list result;

  try {
    // Check the number of parameters
    if (args.length() != 2 or nargout > 1)
      throw (const char*)0;

    // Check S
    if (not args(0).is_matrix_type())
      throw "S should be a matrix";

    // Get S
    Matrix S = args(0).matrix_value();
    octave_idx_type n_dims = S.rows();
    if (S.columns() != n_dims)
      throw "S should be square";

    // Check data
    if (not args(1).is_matrix_type())
      throw "data should be a matrix";

    // Distances
    Matrix distances;

    // Get data
    if (args(1).is_sparse_type()) {
      // As a sparse matrix
      SparseMatrix data = args(1).sparse_matrix_value();

      // Check dimensions
      if (data.rows() != n_dims)
	throw "S and data should have the same number of rows";

      // Find distances
      mahalanobis_distance(distances, S, data, data);
    }
    else {
      // As a dense matrix
      Matrix data = args(1).matrix_value();

      // Check dimensions
      if (data.rows() != n_dims)
	throw "S and data should have the same number of rows";

      // Find distances
      mahalanobis_distance(distances, S, data, data);
    }

    // Prepare output
    result.resize(1);
    result(0) = distances;
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

// Octave callback
DEFUN_DLD(mahalanobis_distance2, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function}\
 {[ @var{dist} ] =} mahalanobis_distance2(@var{S}, @var{source}, @var{target})\n\
\n\
Find the mahalanobis distance between elements of @var{source} and @var{target}\n\
@end deftypefn") {
  // Result
  octave_value_list result;

  try {
    // Check the number of parameters
    if (args.length() != 3 or nargout > 1)
      throw (const char*)0;

    // Check S
    if (not args(0).is_matrix_type())
      throw "S should be a matrix";

    // Get S
    Matrix S = args(0).matrix_value();
    octave_idx_type n_dims = S.rows();
    if (S.columns() != n_dims)
      throw "S should be square";

    // Check source
    if (not args(1).is_matrix_type())
      throw "source should be a matrix";

    // Check target
    if (not args(2).is_matrix_type())
      throw "target should be a matrix";

    // Distances
    Matrix distances;

    // Get source
    if (args(1).is_sparse_type()) {
      // As a sparse matrix
      SparseMatrix source = args(1).sparse_matrix_value();

      // Check dimensions
      if (source.rows() != n_dims)
	throw "S and source should have the same number of rows";

      // Get target
      if (args(2).is_sparse_type()) {
	// As a sparse matrix
	SparseMatrix target = args(2).sparse_matrix_value();

	// Check dimensions
	if (target.rows() != n_dims)
	  throw "S and target should have the same number of rows";

	// Find distances
	mahalanobis_distance(distances, S, source, target);
      }
      else {
	// As a dense matrix
	Matrix target = args(2).matrix_value();

	// Check dimensions
	if (target.rows() != n_dims)
	  throw "S and target should have the same number of rows";

	// Find distances
	mahalanobis_distance(distances, S, source, target);
      }
    }
    else {
      // As a dense matrix
      Matrix source = args(1).matrix_value();

      // Check dimensions
      if (source.rows() != n_dims)
	throw "S and source should have the same number of rows";

      // Get target
      if (args(2).is_sparse_type()) {
	// As a sparse matrix
	SparseMatrix target = args(2).sparse_matrix_value();

	// Check dimensions
	if (target.rows() != n_dims)
	  throw "S and target should have the same number of rows";

	// Find distances
	mahalanobis_distance(distances, S, source, target);
      }
      else {
	// As a dense matrix
	Matrix target = args(2).matrix_value();

	// Check dimensions
	if (target.rows() != n_dims)
	  throw "S and target should have the same number of rows";

	// Find distances
	mahalanobis_distance(distances, S, source, target);
      }
    }

    // Prepare output
    result.resize(1);
    result(0) = distances;
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
