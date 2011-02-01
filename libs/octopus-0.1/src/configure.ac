# Process this file with autoconf to produce a configure script.

# Initialize
AC_INIT([octopus], [0.1], [egonzalez@lsi.upc.edu])
AC_CONFIG_AUX_DIR(config)
AC_CONFIG_SRCDIR([cell_cat.cc])
AC_CONFIG_HEADERS([config.h])
AM_INIT_AUTOMAKE

# Checks for programs.
AC_PROG_CC
AC_PROG_CXX
AC_PROG_F77
AC_CHECK_PROGS([OCTAVE], [octave])
AC_CHECK_PROGS([MKOCTFILE], [mkoctfile])


# C
AC_LANG(C)

# Checks for libraries.
AC_CHECK_LIB([bz2],[BZ2_bzopen],
	     [has_libbz2=true])
AC_CHECK_LIB([z],[gzopen],
	     [has_libz=true])
AC_CHECK_LIB([Rmath],[psigamma],
	     [has_librmath=true],[],[-lm])

# C++
AC_LANG(C++)

# Checks for libraries.

# Checks for header files.
AC_CHECK_HEADERS([boost/regex.hpp],
		 [has_boost_regex_hpp=true])
AC_CHECK_HEADERS([CGAL/QP_models.h],
	         [has_cgal_qp_models=true])
AC_CHECK_HEADERS([ttcl/io/anystream.hxx],
		 [has_ttcl_io_anystream=true])
AC_CHECK_HEADERS([Rmath.h],
                 [has_rmath_h=true],[],
		 [#define MATHLIB_STANDALONE
		 ])

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.

# Octave checks
OCTAVE_RESIZE_AND_FILL

# Conditionals
AM_CONDITIONAL([IN_CONVEX_HULL_MODULE],
	       [test x$has_cgal_qp_models = xtrue])
AM_CONDITIONAL([ISTREAM_MODULE],
	       [test x$has_libbz2 = xtrue -a x$has_libz = xtrue -a x$has_ttcl_io_anystream = xtrue])
AM_CONDITIONAL([QUADPROG_CGAL_MODULE],
	       [test x$has_cgal_qp_models = xtrue])
AM_CONDITIONAL([REGEX_MODULE],
	       [test x$has_boost_regex_hpp = xtrue])
AM_CONDITIONAL([PSI_MODULE],
	       [test x$has_librmath = xtrue -a x$has_rmath_h = xtrue])

# Output
AC_CONFIG_FILES([Makefile])
AC_OUTPUT
