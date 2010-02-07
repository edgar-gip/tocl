####################
# Octfile language #
####################

m4_define([AC_LANG(Octfile)],
[ac_ext=cc
ac_exeext=oct
ac_compile='$MKOCTFILE -c conftest.$ac_ext >&AS_MESSAGE_LOG_FD'
ac_link='MMKOCTFILE conftest.$ac_ext >&AS_MESSAGE_LOG_FD'])

# Compiler
AC_DEFUN([AC_LANG_COMPILER(Octfile)],[])

# Source
m4_define([AC_LANG_SOURCE(Octfile)],[$1])

# Program
m4_define([AC_LANG_PROGRAM(Octfile)],
$1
void f() {
$2
}
)

# Language abreviature
m4_define([_AC_LANG_ABBREV(Octfile)], [oct])

# Prefix
m4_define([_AC_LANG_PREFIX(Octfile)], [OCT])


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
	 AC_DEFINE([RESIZE_AND_FILL],[resize_and_fill],[Octave Matrix resizing method])],
	[AC_MSG_RESULT([[no]])
	 AC_MSG_CHECKING([[if Octave Matrix supports method resize_fill]])
	 AC_COMPILE_IFELSE(
		[AC_LANG_PROGRAM([[@%:@include <octave/oct.h>]],
			         [[Matrix m; m.resize_fill(1, 1, 0);]])],
		[AC_MSG_RESULT([[yes]])
		 AC_DEFINE([RESIZE_AND_FILL],[resize_fill],[Octave Matrix resizing method])])],
		[AC_MSG_RESULT([[no]])
		 AC_ERROR([[Octave Matrix does not support resize_and_fill nor resize_fill]])])])
