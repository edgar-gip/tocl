#include <octave/oct.h>
#include <octave/ov-struct.h>
#include <octave/version.h>


/****************/
/* EM Functions */
/****************/

// Expectation step
void eStep(Matrix& expectation,
	   Matrix& data,
	   Matrix& alpha,
	   Matrix* coefs) {

#ifdef DEBUG
  // DEBUG
  printf("E Step\n");
#endif

  // Find useful sizes
  int nData  = data.rows();
  int nFeats = data.cols();
  int nClust = alpha.rows();

  // For every point
  for (int i = 0; i < nData; ++i) {
    // Total (for normalization)
    double total = 0.0;

    // Find the possibility for each multinomial
    for (int c = 0; c < nClust; ++c) {
      // Prior
      double val = alpha(c);

      // Multinomial components
      for (int f = 0; f < nFeats; ++f) {
	val *= coefs[f](c, int(data(i, f)));
      }

      // Add to matrix and total
      expectation(i, c) = val;
      total += val;
    }

    // Normalize
    if (total != 0.0)
      for (int c = 0; c < nClust; ++c)
	expectation(i, c) /= total;
  }
}


// Expectation step
// Weighted
void eStepW(Matrix& expectation,
	    Matrix& data,
	    Matrix& alpha,
	    Matrix* coefs,
	    Matrix& weights) {

#ifdef DEBUG
  // DEBUG
  printf("E Step W\n");
#endif

  // Find useful sizes
  int nData  = data.rows();
  int nFeats = data.cols();
  int nClust = alpha.rows();

  // For every point
  for (int i = 0; i < nData; ++i) {
    // Total (for normalization)
    double total = 0.0;

    // Find the possibility for each multinomial
    for (int c = 0; c < nClust; ++c) {
      // Prior
      double val = alpha(c);

      // Multinomial components
      for (int f = 0; f < nFeats; ++f) {
	val *= pow(coefs[f](c, int(data(i, f))), weights(f));
      }

      // Add to matrix and total
      expectation(i, c) = val;
      total += val;
    }

    // Normalize
    if (total != 0.0)
      for (int c = 0; c < nClust; ++c)
	expectation(i, c) /= total;
  }
}


// Maximization step
void mStep(Matrix& alpha,
	   Matrix* coefs,
	   Matrix& data,
	   Matrix& expectation) {

#ifdef DEBUG
  // DEBUG
  printf("M Step\n");
#endif

  // Find useful sizes
  int nData  = data.rows();
  int nFeats = data.cols();
  int nClust = alpha.rows();

  // Totals
  double alphaTotal = 0.0;

  // For every point
  for (int i = 0; i < nData; ++i) {
    // For every cluster
    for (int c = 0; c < nClust; ++c) {
      // Add to alpha
      alpha(c)   += expectation(i, c);
      alphaTotal += expectation(i, c);

      // Add to every feature
      for (int f = 0; f < nFeats; ++f) {
	int idx = int(data(i, f));

#ifdef DEBUG
	// Check index validity
	if (idx < 0 || idx >= coefs[f].cols()) {
	  printf("Error! i: %d c: %d f: %d idx: %d\nPrepare to die!\n",
		 i, c, f, idx);
	}
#endif

	coefs[f](c, idx) += expectation(i, c);
      }
    }
  }

  // Normalize alphas
  if (alphaTotal != 0.0)
    for (int c = 0; c < nClust; ++c)
      alpha(c) /= alphaTotal;

  // Normalize coefs
  for (int f = 0; f < nFeats; ++f) {
    int nValues = coefs[f].cols();
    for (int c = 0; c < nClust; ++c) {
      double valTotal = 0.0;
      for (int v = 0; v < nValues; ++v)
	valTotal += coefs[f](c, v);

      if (valTotal != 0.0)
	for (int v = 0; v < nValues; ++v)
	  coefs[f](c, v) /= valTotal;
    }
  }
}


// Log-Likelihood of data
double logLike(Matrix& alpha,
	       Matrix* coefs,
	       Matrix& data) {

#ifdef DEBUG
  // DEBUG
  printf("Log-Likelihood\n");
#endif

  // Find useful sizes
  int nData  = data.rows();
  int nFeats = data.cols();
  int nClust = alpha.rows();

  // Total
  double llike = 0.0;

  // For every point
  for (int i = 0; i < nData; ++i) {
    // The single factor
    double factor = 0.0;

    // For every cluster
    for (int c = 0; c < nClust; ++c) {
      // The single term
      double term = alpha(c);

      // For every feature
      for (int f = 0; f < nFeats; ++f) {
	int idx = int(data(i, f));

#ifdef DEBUG
	// Check index validity
	if (idx < 0 || idx >= coefs[f].cols()) {
	  printf("Error! i: %d c: %d f: %d idx: %d\nPrepare to die!\n",
		 i, c, f, idx);
	}
#endif

	// Add to the term
	term *= coefs[f](c, idx);
      }

      // Add to the factor
      factor += term;
    }

    // Add to the total
    llike += log(factor);
  }

  // Return it
  return llike;
}


// Log-Likelihood of data
// Weighted
double logLikeW(Matrix& alpha,
		Matrix* coefs,
		Matrix& data,
		Matrix& weights) {

#ifdef DEBUG
  // DEBUG
  printf("Log-Likelihood W\n");
#endif

  // Find useful sizes
  int nData  = data.rows();
  int nFeats = data.cols();
  int nClust = alpha.rows();

  // Total
  double llike = 0.0;

  // For every point
  for (int i = 0; i < nData; ++i) {
    // The single factor
    double factor = 0.0;

    // For every cluster
    for (int c = 0; c < nClust; ++c) {
      // The single term
      double term = alpha(c);

      // For every feature
      for (int f = 0; f < nFeats; ++f) {
	int idx = int(data(i, f));

#ifdef DEBUG
	// Check index validity
	if (idx < 0 || idx >= coefs[f].cols()) {
	  printf("Error! i: %d c: %d f: %d idx: %d\nPrepare to die!\n",
		 i, c, f, idx);
	}
#endif

	// Add to the term
	term *= pow(coefs[f](c, idx), weights(f));
      }

      // Add to the factor
      factor += term;
    }

    // Add to the total
    llike += log(factor);
  }

  // Return it
  return llike;
}


/*******************/
/* Octave-C++ Glue */
/*******************/

// Perform an expectation step
DEFUN_DLD(comb_mem_expectation, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {Expectation =} comb_mem_expectation(@var{model}, @var{data})\n\
\n\
Perform an expectation step.\n\
@end deftypefn") {
  // Check argument number
  if (args.length() != 2 || nargout > 1) {
    print_usage("comb_mem_expectation");
    return octave_value_list();
  }

  // Check types of arguments
  if (!args(0).is_map()) {
    error("MODEL should be a struct");
    return octave_value_list();
  }

  if (!args(1).is_real_matrix()) {
    error("DATA should be a matrix");
    return octave_value_list();
  }

  // Find the kind element of the struct
  Octave_map model         = args(0).map_value();
  Octave_map::iterator iki = model.seek("kind");
  if (iki == model.end()) {
    error("MODEL does not have a kind field");
    return octave_value_list();
  }

  // Find the kind
  if (!model.contents(iki)(0).is_real_scalar()) {
    error("MODEL.kind should be an integer");
    return octave_value_list();
  }
  int kind = model.contents(iki)(0).int_value();

  // Check supported kinds
  if (kind < 1 || kind > 2) {
    error("MODEL.kind unsupported");
    return octave_value_list();
  }

  // Find the alpha element of the struct
  Octave_map::iterator ial = model.seek("alpha");
  if (ial == model.end()) {
    error("MODEL does not have an alpha field");
    return octave_value_list();
  }

  // Find the alpha matrix
  if (!model.contents(ial)(0).is_real_matrix()) {
    error("MODEL.alpha should be a matrix");
    return octave_value_list();
  }
  Matrix alpha = model.contents(ial)(0).matrix_value();

  // Find the coefs element of the struct
  Octave_map::iterator ico = model.seek("coefs");
  if (ico == model.end()) {
    error("MODEL does not have a coefs field");
    return octave_value_list();
  }

  // Find the contents
  if (!model.contents(ico)(0).is_cell()) {
    error("MODEL.coefs should be a cell");
    return octave_value_list();
  }
  Cell ccoefs = model.contents(ico)(0).cell_value();

  // Make a matrix array
  Matrix* coefs = new Matrix[ccoefs.cols()];
  for (int c = 0; c < ccoefs.cols(); ++c) {
    if (!ccoefs(c).is_real_matrix()) {
      error("MODEL.coefs should contain matrices");
      delete[] coefs;
      return octave_value_list();
    }
    coefs[c] = ccoefs(c).matrix_value();
  }

  // Find the data
  Matrix data = args(1).matrix_value();

  // Sizes
  int nData  = data.rows();
  int nClust = alpha.rows();

  // Return value
  Matrix expectation(nData, nClust, 0.0);

  // According to the kind
  switch (kind) {
  case 1:
    // Unweighted
    // Call the function
    eStep(expectation, data, alpha, coefs);
    break;

  case 2:
    // Find the weights element of the struct
    Octave_map::iterator iwe = model.seek("weights");
    if (iwe == model.end()) {
      error("MODEL does not have a weights field");
      delete[] coefs;
      return octave_value_list();
    }

    // Find the weights matrix
    if (!model.contents(iwe)(0).is_real_matrix()) {
      error("MODEL.weights should be a matrix");
      delete[] coefs;
      return octave_value_list();
    }
    Matrix weights = model.contents(iwe)(0).matrix_value();

    // Call the function
    eStepW(expectation, data, alpha, coefs, weights);
  }

  // Free the coefs array
  delete[] coefs;

  // Return
  octave_value_list output;
  output.resize(1);
  output(0) = octave_value(expectation);
  return output;
}


// Perform a maximization step
DEFUN_DLD(comb_mem_maximization, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {model =} comb_mem_maximization(@var{data}, @var{FeatureSizes}, @var{expectation})\n\
\n\
Perform an expectation step.\n\
@end deftypefn") {
  // Check argument number
  if (args.length() != 3 || nargout > 1) {
    print_usage("comb_mem_maximization");
    return octave_value_list();
  }

  // Check types of arguments
  if (!args(0).is_real_matrix()) {
    error("DATA should be a matrix");
    return octave_value_list();
  }

  if (!args(1).is_real_matrix()) {
    error("FEATURESIZES should be a column vector");
    return octave_value_list();
  }

  if (!args(2).is_real_matrix()) {
    error("EXPECTATION should be a matrix");
    return octave_value_list();
  }

  // Get the matrices
  Matrix data         = args(0).matrix_value();
  Matrix featureSizes = args(1).matrix_value();
  Matrix expectation  = args(2).matrix_value();

  // Check dimensions of DATA and EXPECTATION
  int nData = data.rows();
  if (expectation.rows() != nData) {
    error("DATA and EXPECTATION should have the same number of rows");
    return octave_value_list();
  }

  // Check dimensions of FEATURESIZES
  int nFeats = data.cols();
  if (featureSizes.cols() != 1) {
    error("FEATURESIZES should be a column vector");
    return octave_value_list();
  }

  if (featureSizes.rows() != nFeats) {
    error("FEATURESIZES does not match the number of features in DATA");
    return octave_value_list();
  }

  // Output alpha
  int nClust = expectation.cols();
  Matrix alpha(nClust, 1, 0.0);

  // Output coefs
  Matrix* coefs = new Matrix[nFeats];
  for (int f = 0; f < nFeats; ++f) {
    coefs[f].resize_fill(nClust, int(featureSizes(f)), 0.0);
  }

  // Call
  mStep(alpha, coefs, data, expectation);

  // Create the coefs cell
  Cell ccoefs(1, nFeats);
  for (int f = 0; f < nFeats; ++f)
    ccoefs(f) = octave_value(coefs[f]);

  // Free the coefs array
  delete[] coefs;

  // Return
  Octave_map model;
  model.assign("kind",  octave_value(1));
  model.assign("alpha", octave_value(alpha));
  model.assign("coefs", Cell(octave_value(ccoefs)));

  // Return
  octave_value_list output;
  output.resize(1);
  output(0) = octave_value(model);
  return output;
}


// Find the log likelihood
DEFUN_DLD(comb_mem_loglike, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {logLike =} comb_mem_loglike(@var{model}, @var{data})\n\
\n\
Find the log-likelihood of data according to the model.\n\
@end deftypefn") {
  // Check argument number
  if (args.length() != 2 || nargout > 1) {
    print_usage("comb_mem_loglike");
    return octave_value_list();
  }

  // Check types of arguments
  if (!args(0).is_map()) {
    error("MODEL should be a struct");
    return octave_value_list();
  }

  if (!args(1).is_real_matrix()) {
    error("DATA should be a matrix");
    return octave_value_list();
  }

  // Find the kind element of the struct
  Octave_map model         = args(0).map_value();
  Octave_map::iterator iki = model.seek("kind");
  if (iki == model.end()) {
    error("MODEL does not have a kind field");
    return octave_value_list();
  }

  // Find the kind
  if (!model.contents(iki)(0).is_real_scalar()) {
    error("MODEL.kind should be an integer");
    return octave_value_list();
  }
  int kind = model.contents(iki)(0).int_value();

  // Check supported kinds
  if (kind < 1 || kind > 2) {
    error("MODEL.kind unsupported");
    return octave_value_list();
  }

  // Find the alpha element of the struct
  Octave_map::iterator ial = model.seek("alpha");
  if (ial == model.end()) {
    error("MODEL does not have an alpha field");
    return octave_value_list();
  }

  // Find the alpha matrix
  if (!model.contents(ial)(0).is_real_matrix()) {
    error("MODEL.alpha should be a matrix");
    return octave_value_list();
  }
  Matrix alpha = model.contents(ial)(0).matrix_value();

  // Find the coefs element of the struct
  Octave_map::iterator ico = model.seek("coefs");
  if (ico == model.end()) {
    error("MODEL does not have a coefs field");
    return octave_value_list();
  }

  // Find the contents
  if (!model.contents(ico)(0).is_cell()) {
    error("MODEL.coefs should be a cell");
    return octave_value_list();
  }
  Cell ccoefs = model.contents(ico)(0).cell_value();

  // Make a matrix array
  Matrix* coefs = new Matrix[ccoefs.cols()];
  for (int c = 0; c < ccoefs.cols(); ++c) {
    if (!ccoefs(c).is_real_matrix()) {
      error("MODEL.coefs should contain matrices");
      delete[] coefs;
      return octave_value_list();
    }
    coefs[c] = ccoefs(c).matrix_value();
  }

  // Find the data
  Matrix data = args(1).matrix_value();

  // According to the kind
  double llike;
  switch (kind) {
  case 1:
    // Unweighted
    // Call the function
    llike = logLike(alpha, coefs, data);

  case 2:
    // Find the weights element of the struct
    Octave_map::iterator iwe = model.seek("weights");
    if (iwe == model.end()) {
      error("MODEL does not have a weights field");
      delete[] coefs;
      return octave_value_list();
    }

    // Find the weights matrix
    if (!model.contents(iwe)(0).is_real_matrix()) {
      error("MODEL.weights should be a matrix");
      delete[] coefs;
      return octave_value_list();
    }
    Matrix weights = model.contents(iwe)(0).matrix_value();

    // Call the function
    llike = logLikeW(alpha, coefs, data, weights);
  }

  // Free the coefs array
  delete[] coefs;

  // Return
  octave_value_list output;
  output.resize(1);
  output(0) = octave_value(llike);
  return output;
}

