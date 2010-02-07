AM_CPPFLAGS = -I../include
AM_CXXFLAGS = -Wall -Wextra

SUFFIXES = .oct

noinst_DATA = cell.oct matrix.oct misc.oct
EXTRA_DATA  = istream.oct regex.oct

if ISTREAM_MODULE
noinst_DATA  += istream.oct
istream_LDADD = -lbz2 -lz
endif

if QUADPROG_CGAL_MODULE
noinst_DATA += quadprog_cgal.oct
quadprog_cgal_LDADD = -lCGAL
quadprog_cgal_SOURCES = quadprog_common.cc
endif

if REGEX_MODULE
noinst_DATA += regex.oct
regex_LDADD  = -lboost_regex
endif

.cc.oct:
	$(MKOCTFILE) $(CPPFLAGS) $($*_OCTFLAGS) $(DEFS) $^ $($*_SOURCES) $(LDFLAGS) $($*_LDADD)
