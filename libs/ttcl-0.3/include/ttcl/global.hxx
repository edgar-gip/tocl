#ifndef TTCL_GLOBAL_HXX
#define TTCL_GLOBAL_HXX

// TTCL: The Template Clustering Library

/** @file
    Global Definitions
    @author Edgar Gonz�lez i Pellicer
*/

/// Null pointer
#define ttcl_nullptr (void*)(0)

/// printf()-like Format Check
#ifdef __GNUC__
#define ttcl_printf_check(str_idx, par_idx)		\
  __attribute__((format(printf, str_idx, par_idx)))
#else
#define ttcl_printf_check()
#endif

#endif