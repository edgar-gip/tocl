#include <cmath>
#include <exception>
// #include <iostream>

#include <octave/oct.h>

// Helper function
template <typename SMatrix, typename TMatrix>
static void skl_divergence(Matrix& _distances,
			   double _term,
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
      // Accumulate
      double sum = 0.0;
      for (octave_idx_type i = 0; i < n_dims; ++i)
	sum += (_term + _target(i, tgt))
	     * std::log((_term + _target(i, tgt)) / (_term + _source(i, src)));

      // Set
      _distances(src, tgt) = sum / (1 + _term * n_dims);
    }
  }
}

// Specialization for two sparse matrices
static void skl_divergence(Matrix& _distances,
			   double _term,
			   const SparseMatrix& _source,
			   const SparseMatrix& _target) {
  // Number of dimensions
  octave_idx_type n_dims = _source.rows(); // == _target.rows();

  // Number of source samples
  octave_idx_type n_src = _source.columns();

  // Number of target samples
  octave_idx_type n_tgt = _target.columns();

  // Resize distances
  _distances.resize(n_src, n_tgt, 0.0);

  // Get arrays
  const octave_idx_type* src_cidx = _source.cidx();
  const octave_idx_type* src_ridx = _source.ridx();
  const double*          src_data = _source.data();
  const octave_idx_type* tgt_cidx = _target.cidx();
  const octave_idx_type* tgt_ridx = _target.ridx();
  const double*          tgt_data = _target.data();

  // For each source
  for (octave_idx_type src = 0; src < n_src; ++src) {

    // For each target
    for (octave_idx_type tgt = 0; tgt < n_tgt; ++tgt) {

      // Accumulate
      double sum = 0.0;

      // Merge-sortish
      octave_idx_type src_i = src_cidx[src];
      octave_idx_type tgt_i = tgt_cidx[tgt];
      while (src_i < src_cidx[src + 1] and
	     tgt_i < tgt_cidx[tgt + 1]) {
	// What?
	if (src_ridx[src_i] < tgt_ridx[tgt_i]) {
	  // Advance source
	  ++src_i;
	}
	else if (src_ridx[src_i] > tgt_ridx[tgt_i]) {
	  // Advance target
	  ++tgt_i;
	}
	else { // src_ridx[src_i] == tgt_ridx[tgt_i]
	  // Update
	  sum += (_term + tgt_data[tgt_i])
	       * std::log((_term + tgt_data[tgt_i]) /
			  (_term + src_data[src_i]));

	  // Advance both
	  ++src_i;
	  ++tgt_i;
	}
      }

      // Set
      _distances(src, tgt) = sum / (1 + _term * n_dims);
    }
  }
}

// Octave callback
DEFUN_DLD(skl_divergence1, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function}\
 {[ @var{dist} ] =} skl_divergence1(@var{term}, @var{source})\n\
\n\
Find the smoothed kullback-leibler divergence between elements of @var{source}\n\
@end deftypefn") {
  // Result
  octave_value_list result;

  try {
    // Check the number of parameters
    if (args.length() != 2 or nargout > 1)
      throw (const char*)0;

    // Check term
    if (not args(0).is_scalar_type())
      throw "term should be a scalar";

    // Check data
    if (not args(1).is_matrix_type())
      throw "data should be a matrix";

    // Distances
    Matrix distances;

    // Get term
    double term = args(0).scalar_value();

    // Get data
    if (args(1).is_sparse_type()) {
      // As a sparse matrix
      SparseMatrix data = args(1).sparse_matrix_value();

      // Find distances
      skl_divergence(distances, term, data, data);
    }
    else {
      // As a dense matrix
      Matrix data = args(1).matrix_value();

      // Find distances
      skl_divergence(distances, term, data, data);
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
DEFUN_DLD(skl_divergence2, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function}\
 {[ @var{dist} ] =} skl_divergence2(@var{term}, @var{source}, @var{target})\n\
\n\
Find the smoothed kullback-leibler divergence between elements of @var{source} and @var{target}\n\
@end deftypefn") {
  // Result
  octave_value_list result;

  try {
    // Check the number of parameters
    if (args.length() != 3 or nargout > 1)
      throw (const char*)0;

    // Check term
    if (not args(0).is_scalar_type())
      throw "term should be a scalar";

    // Check source
    if (not args(1).is_matrix_type())
      throw "source should be a matrix";

    // Check target
    if (not args(2).is_matrix_type())
      throw "target should be a matrix";

    // Distances
    Matrix distances;

    // Get term
    double term = args(0).scalar_value();

    // Get source
    if (args(1).is_sparse_type()) {
      // As a sparse matrix
      SparseMatrix source = args(1).sparse_matrix_value();

      // Get target
      if (args(2).is_sparse_type()) {
	// As a sparse matrix
	SparseMatrix target = args(2).sparse_matrix_value();

	// Check dimensions
	if (source.rows() != target.rows())
	  throw "source and target should have the same number of rows";

	// Find distances
	skl_divergence(distances, term, source, target);
      }
      else {
	// As a dense matrix
	Matrix target = args(2).matrix_value();

	// Check dimensions
	if (source.rows() != target.rows())
	  throw "source and target should have the same number of rows";

	// Find distances
	skl_divergence(distances, term, source, target);
      }
    }
    else {
      // As a dense matrix
      Matrix source = args(1).matrix_value();

      // Get target
      if (args(2).is_sparse_type()) {
	// As a sparse matrix
	SparseMatrix target = args(2).sparse_matrix_value();

	// Check dimensions
	if (source.rows() != target.rows())
	  throw "source and target should have the same number of rows";

	// Find distances
	skl_divergence(distances, term, source, target);
      }
      else {
	// As a dense matrix
	Matrix target = args(2).matrix_value();

	// Check dimensions
	if (source.rows() != target.rows())
	  throw "source and target should have the same number of rows";

	// Find distances
	skl_divergence(distances, term, source, target);
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
