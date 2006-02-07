#include <octave/oct.h>


/*********************/
/* Occurrency matrix */
/*********************/

// Find the occurrency matrix
void occMatrix(Matrix& occurrency,
	       Matrix& cl1,
	       Matrix& cl2,
	       int nelems) {
  // For every point
  for (int i = 0; i < nelems; ++i) {
    ++occurrency(int(cl1(i)), int(cl2(i)));
  }
}


// Maximum value of a matrix
int matrixMax(Matrix& mat,
	      int nelems) {
  // Starting max
  double maxim = mat(0);

  // For every point
  for (int i = 1; i < nelems; ++i) {
    if (mat(i) > maxim)
      maxim = mat(i);
  }

  // Return it casted to int
  return int(maxim);
}


/*******************/
/* Octave-C++ Glue */
/*******************/

// Find the occurrency matrix
DEFUN_DLD(meas_occ, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {M =} meas_occ(@var{cl1}, @var{cl2})\n\
\n\
Find the occurrency matrix between two clusters.\n\
@end deftypefn") {
  // Check argument number
  if (args.length() != 2 || nargout != 1) {
    print_usage("meas_occ");
    return octave_value_list();
  }

  // Check types of arguments
  if (!args(0).is_real_matrix() || !args(1).is_real_matrix()) {
    error("CL1 and CL2 should be column vectors");
    return octave_value_list();
  }

  // Find the matrices
  Matrix cl1 = args(0).matrix_value();
  Matrix cl2 = args(1).matrix_value();

  // Ensure they are column vectors
  if (cl1.cols() != 1 || cl2.cols() != 1) {
    error("CL1 and CL2 should be column vectors");
    return octave_value_list();
  }

  // Size
  int nelems = cl1.rows();

  // Ensure they are the same
  if (cl2.rows() != nelems) {
    error("CL1 and CL2 should have the same size");
    return octave_value_list();
  }

  // Find number of different labels
  int max1 = matrixMax(cl1, nelems);
  int max2 = matrixMax(cl2, nelems);

  // Return value
  Matrix occurrency(max1 + 1, max2 + 1, 0.0);
  
  // Call the function
  occMatrix(occurrency, cl1, cl2, nelems);

  // Return
  octave_value_list output;
  output.resize(1);
  output(0) = octave_value(occurrency);
  return output;
}
