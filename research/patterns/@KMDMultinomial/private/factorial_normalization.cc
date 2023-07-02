#include <cmath>
#include <exception>
// #include <iostream>
#include <vector>

#include <octave/oct.h>

// Log factorial cache
static std::vector<double> log_factorial_cache(2, 0.0);

// Log factorial
static inline double log_factorial(unsigned int _n) {
  // Already there?
  if (_n >= log_factorial_cache.size()) {
    // Resize
    log_factorial_cache.reserve(_n + 1);

    // Find them
    for (unsigned int i = log_factorial_cache.size(); i <= _n; ++i) {
      // Calculate
      log_factorial_cache.push_back(log_factorial_cache.back() + std::log(i));

      // Debug
      // std::cerr << i << "! = " << log_factorial_cache[i] << std::endl;
    }
  }

  // Return it
  return log_factorial_cache[_n];
}

// Helper function
static void find_factorial_normalization(RowVector& _fnorm,
                                         const SparseMatrix& _data) {
  // Sizes
  octave_idx_type n_cols = _data.columns();

  // Get arrays
  const octave_idx_type* cidx = _data.cidx();
  const octave_idx_type* ridx = _data.ridx();
  const double*          nnz  = _data.data();

  // For each column
  for (octave_idx_type c = 0; c < n_cols; ++c) {
    // Factor denominator
    double log_denom = 0.0;

    // Sum
    unsigned int sum = 0;

    // Index
    for (octave_idx_type p = cidx[c]; p < cidx[c + 1]; ++p) {
      // Convert
      unsigned int x = nnz[p];

      // Add term to denominator
      log_denom += log_factorial(x);

      // Add
      sum += x;
    }

    // Finish calculation
    _fnorm(c) = log_factorial(sum) - log_denom;
  }
}

// Octave callback
DEFUN_DLD(factorial_normalization, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function}\
 {[ @var{fnorm} ] =} factorial_normalization(@var{data})\n\
\n\
Find the \n\
@end deftypefn") {
  // Result
  octave_value_list result;

  try {
    // Check the number of parameters
    if (args.length() != 1 or nargout != 1)
      throw (const char*)0;

    // Check data
    if (not args(0).is_sparse_type())
      throw "data should be a sparse matrix";

    // Get data
    SparseMatrix data = args(0).sparse_matrix_value();

    // Normalization
    RowVector fnorm(data.columns());

    // Find it
    find_factorial_normalization(fnorm, data);

    // Prepare output
    result.resize(1);
    result(0) = fnorm;
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
