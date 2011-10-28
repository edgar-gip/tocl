#include <iostream>

#include <octave/oct.h>


/***************************************************/
/* Find the affinity from the co-occurrence vector */
/***************************************************/

static void
_affinity(Matrix& _aff, const Matrix& _co_occ, const RowVector& _truth) {
  // Sizes
  octave_idx_type n_data     = _co_occ.rows();
  octave_idx_type n_clusters = octave_idx_type(_truth.max());

  // Resize output
#ifdef OCTAVE_3_4
  _aff.resize(n_clusters, n_clusters, 0.0);
#else
  _aff.resize_fill(n_clusters, n_clusters, 0.0);
#endif

  // Denominator
  Matrix dens(n_clusters, n_clusters, 0.0);

  // Cluster sizes
  RowVector sizes(n_clusters, 0.0);

  // For each sample
  for (octave_idx_type i = 0; i < n_data; ++i) {
    // Cluster
    octave_idx_type cl_i = octave_idx_type(_truth(i)) - 1;

    // Count for size
    ++sizes(cl_i);

    // Add self-affinity
    _aff(cl_i, cl_i) += _co_occ(i, i);
    dens(cl_i, cl_i) += 1.0;

    // For each other sample
    for (octave_idx_type j = 0; j < i; ++j) {
      // Cluster
      octave_idx_type cl_j = octave_idx_type(_truth(j)) - 1;

      // Add
      _aff(cl_i, cl_j) += _co_occ(i, j);
      _aff(cl_j, cl_i) += _co_occ(j, i);

      dens(cl_i, cl_j) += 1.0;
      dens(cl_j, cl_i) += 1.0;
    }
  }

  // Now divide
  for (octave_idx_type cl_i = 0; cl_i < n_clusters; ++cl_i) {
    for (octave_idx_type cl_j = 0; cl_j < n_clusters; ++cl_j) {
      // Denominator
      double den = sizes(cl_i) * sizes(cl_j);

      // Check
      if (den != dens(cl_i, cl_j))
	std::cerr << cl_i << ',' << cl_j << " = " << den << " != "
		  << dens(cl_i, cl_j) << std::endl;

      // Divide
      if (den != 0.0)
	_aff(cl_i, cl_j) /= den;
    }
  }
}

DEFUN_DLD(affinity, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function}\
 {[ @var{aff} ] =} affinity(@var{co_occurrence}, @var{truth})\n\
\n\
Find the affinity matrix from the co-occurrence vector\n\
@end deftypefn") {
  // Result
  octave_value_list result;

  try {
    // Check the number of parameters
    if (args.length() != 2 or nargout > 1)
      throw (const char*)0;

    // Check co_occ
    if (not args(0).is_matrix_type())
      throw "co_occ should be a matrix";

    // Get co_occ
    Matrix co_occ = args(0).matrix_value();
    octave_idx_type n_data = co_occ.rows();
    if (co_occ.columns() != n_data)
      throw "co_occ should be square";

    // Check data
    if (not args(1).is_matrix_type())
      throw "truth should be a row vector";

    // Get truth
    Matrix truth_m = args(1).matrix_value();
    if (truth_m.rows() != 1)
      throw "truth should be a row vector";
    if (truth_m.columns() != n_data)
      throw "The number of columns of truth and co_occ should match";

    // Get truth
    RowVector truth = args(1).row_vector_value();

    // Find the output
    Matrix aff;
    _affinity(aff, co_occ, truth);

    // Set the result
    result.resize(1);
    result(0) = aff;
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
