#include <cmath>
#include <exception>

#include <octave/oct.h>

#define MATHLIB_STANDALONE
#include <Rmath.h>


/*****************************************************************/
/* Estimate the alpha parameters in Dirichlet clusters           */
/*  Thomas P. Minka, "Estimating a Dirichlet Distribution", 2003 */
/*****************************************************************/

// Thresholds
static const int    ITERATIONS = 1000;
static const double THRESHOLD  = 1e-12;

// Inverse digamma function
/* Solved by the Newton-Raphson Method
   (Minka, 2003; Appendix C)
*/
static double digamma_inv(double y) {
  // Starting solution
  /* (Minka, 2003; Formula 135)
   */
  const double EULER = 0.5772156649;
  double x;
  if (y < -2.22)
    x = -1.0 / (y + EULER);
  else
    x = std::exp(y) + 0.5;
  double f = digamma(x) - y;

  // Loop
  for (int i = 0; i < ITERATIONS; ++i) {
    // Update
    /* x = x - f(x) / f'(x)
     */
    x -= f / trigamma(x);
    if (x < THRESHOLD)
      x = THRESHOLD;

    // New function value
    f = digamma(x) - y;
    
    // Exit if the function is close enough to zero
    if (std::abs(f) < THRESHOLD)
      break;
  }
  
  // Return the result
  return x;
}

// Estimate the parameters of a Dirichlet distribution
/* Solved by an Interior Point Method
   (Minka, 2003; Formula 9)
 */
static void
dirichlet_estimate(Matrix& _alpha, Matrix& _z,
		   const Matrix& _suff,
		   octave_idx_type _cl, octave_idx_type _bl,
		   octave_idx_type _start, octave_idx_type _end) {
  // Start with an equal solution
  double eq_alpha = 1.0 / (_end - _start);
  for (int j = _start; j < _end; ++j)
    _alpha(_cl, j) = eq_alpha;
  double sum_alpha = 1.0;

  // Loop
  for (int i = 0; i < ITERATIONS; ++i) {
    // Digamma of the sum of alphas
    double dig_sum_alpha = digamma(sum_alpha);

    // Total amount of change
    double change = 0.0;
    
    // Each feature
    sum_alpha = 0.0;
    for (int j = _start; j < _end; ++j) {
      // New alpha 
      /* Remember _suff is (n_dims * k)
       */
      double new_alpha = digamma_inv(dig_sum_alpha + _suff(j, _cl));

      // Change
      change += (_alpha(_cl, j) - new_alpha) * (_alpha(_cl, j) - new_alpha);

      // Update
      sum_alpha += (_alpha(_cl, j) = new_alpha);
    }

    // Exit?
    if (change < THRESHOLD)
      break;
  }

  // Find the normalization factor
  double prod_gamma = 1.0;
  for (int j = _start; j < _end; ++j)
    prod_gamma *= gammafn(_alpha(_cl, j));
  _z(_cl, _bl) = prod_gamma / gammafn(sum_alpha);
}

// Octave callback
DEFUN_DLD(dirichlet_estimation, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function}\
 {[ @var{alpha}, @var{Z} ] =} dirichlet_estimation(@var{blocks}, @var{suff})\n\
\n\
Estimate the alpha parameters in Dirichlet clusters\n\
@end deftypefn") {
  // Result
  octave_value_list result;

  try {
    // Check the number of parameters
    if (args.length() != 2 or nargout < 1)
      throw (const char*)0;
  
    // Get blocks
    Array<int> blocks = args(0).int_vector_value();
    octave_idx_type n_blocks = blocks.length();

    // Sum them
    octave_idx_type n_dims = 0;
    for (octave_idx_type bl = 0; bl < n_blocks; ++bl)
      n_dims += blocks(bl);

    // Check suff
    if (not args(1).is_matrix_type()) {
      throw "suff should be a matrix";
    }
    else if (args(1).rows() != n_dims) {
      throw "suff should have as many rows as the total block size";
    }
    Matrix suff = args(1).matrix_value();

    // Number of clusters
    octave_idx_type k = suff.columns();

    // Output
    Matrix alpha(k, n_dims);
    Matrix z    (k, n_blocks);

    // For each cluster
    for (octave_idx_type cl = 0; cl < k; ++cl) {
      // For each block
      octave_idx_type start = 0;
      for (octave_idx_type bl = 0; bl < blocks.length(); ++bl) {
	// Estimate from suff(k, start : start + blocks(bl) - 1)
	dirichlet_estimate(alpha, z, suff, cl, bl, start, start + blocks(bl));

	// Next block start
	start += blocks(bl);
      }
    }

    // Prepare output
    result.resize(2);
    result(0) = alpha;
    result(1) = z;
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
