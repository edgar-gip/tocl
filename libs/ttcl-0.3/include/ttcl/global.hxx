#ifndef TTCL_GLOBAL_HXX
#define TTCL_GLOBAL_HXX

// TTCL: The Template Clustering Library

/** @file
    Global Definitions
    @author Edgar Gonzàlez i Pellicer
*/

/// printf()-like Format Check
#ifdef __GNUC__
#define TTCL_PRINTF_CHECK(str_idx, par_idx)		\
  __attribute__((format(printf, str_idx, par_idx)))
#else
#define TTCL_PRINTF_CHECK()
#endif

/// Import type
#define TTCL_IMPORT_TYPE(class, type)		\
  typedef typename class::type type

/// Import and rename type
#define TTCL_IMPORT_R_TYPE(class, type, newtype)	\
  typedef typename class::type newtype

#endif
