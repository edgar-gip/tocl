####################
# Octfile language #
####################

# AC_LANG(Octfile)
# ---------------
AC_LANG_DEFINE([Octfile], [oct], [OCT], [MKOCTFILE], [],
[ac_ext=cc
ac_exeext=oct
ac_compile='$MKOCTFILE -c conftest.$ac_ext >&AS_MESSAGE_LOG_FD'
ac_link='$MKOCTFILE conftest.$ac_ext >&AS_MESSAGE_LOG_FD'
])

# Compiler
AC_DEFUN([AC_LANG_COMPILER(Octfile)],[])

# Program
m4_define([AC_LANG_PROGRAM(Octfile)],
[$1
void f() {
$2
}
])


#########
# Tests #
#########

# Determine the Octave function for resize and fill
AC_DEFUN([OCTAVE_RESIZE_AND_FILL],
[AC_LANG_PUSH(Octfile)

 AC_MSG_CHECKING([[if Octave Matrix supports method resize_and_fill]])
 AC_COMPILE_IFELSE(
	[AC_LANG_PROGRAM([[@%:@include <octave/oct.h>]],
		         [[Matrix m; m.resize_and_fill(1, 1, 0);]])],
	[AC_MSG_RESULT([[yes]])
	 AC_DEFINE([RESIZE_AND_FILL],[resize_and_fill],[Octave Matrix resizing method])
	 ac_ac_octave_resize_and_fill_found=yes],
	[AC_MSG_RESULT([[no]])])

 if test "x$ac_ac_octave_resize_and_fill_found" != xyes; then
 AC_MSG_CHECKING([[if Octave Matrix supports method resize_fill]])
 AC_COMPILE_IFELSE(
	[AC_LANG_PROGRAM([[@%:@include <octave/oct.h>]],
		         [[Matrix m; m.resize_fill(1, 1, 0);]])],
	[AC_MSG_RESULT([[yes]])
	 AC_DEFINE([RESIZE_AND_FILL],[resize_fill],[Octave Matrix resizing method])
	 ac_ac_octave_resize_and_fill_found=yes],
	[AC_MSG_RESULT([[no]])])
 fi

 if test "x$ac_ac_octave_resize_and_fill_found" != xyes; then
 AC_MSG_CHECKING([[if Octave Matrix supports method resize]])
 AC_COMPILE_IFELSE(
	[AC_LANG_PROGRAM([[@%:@include <octave/oct.h>]],
		         [[Matrix m; m.resize(1, 1, 0);]])],
	[AC_MSG_RESULT([[yes]])
	 AC_DEFINE([RESIZE_AND_FILL],[resize],[Octave Matrix resizing method])
	 AC_DEFINE([RESIZE_VECTOR_ONE_ARG],[],[Octave Matrix resize(...) takes one argument for *Vector types])],
	[AC_MSG_RESULT([[no]])])
 fi

 AC_LANG_POP(Octfile)])
