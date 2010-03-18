# Flags
AM_CPPFLAGS = -I../include
AM_CXXFLAGS = -Wall -Wextra

# Suffices
SUFFIXES = .oct

# Modules
noinst_DATA = array_zip.oct cell_cat.oct \
	      isfunctionhandle.oct matrix_rankize.oct
EXTRA_DATA  = istream_open.oct quadprog_cgal.oct regex_match.oct


# Generic
.cc.oct:
	$(MKOCTFILE) $(CPPFLAGS) $($*_OCTFLAGS) $(DEFS) $^ $($*_SOURCES) $(LDFLAGS) $($*_LDADD)


# istream
if ISTREAM_MODULE
noinst_DATA  += istream_open.oct
istream_open_LDADD = -lbz2 -lz
endif


# quadprog_cgal
if QUADPROG_CGAL_MODULE
noinst_DATA += quadprog_cgal.oct
quadprog_cgal_LDADD = -lCGAL
quadprog_cgal_SOURCES = quadprog_common.cc
quadprog_cgal_CXXFLAGS = -g -frounding-math -Wall -Wextra -fPIC

quadprog_cgal.oct: quadprog_cgal.cc $(quadprog_cgal_SOURCES)
	CXXFLAGS="$(quadprog_cgal_CXXFLAGS)" $(MKOCTFILE) $(CPPFLAGS) $(quadprog_cgal_OCTFLAGS) $(DEFS) $^ $(LDFLAGS) $(quadprog_cgal_LDADD)
endif


# regex
if REGEX_MODULE
noinst_DATA += regex_match.oct
regex_match_LDADD  = -lboost_regex
endif
