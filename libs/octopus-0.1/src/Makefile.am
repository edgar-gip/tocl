# Flags
AM_CPPFLAGS = -I../include
AM_CXXFLAGS = -Wall -Wextra

# Suffices
SUFFIXES = .oct

# Modules
noinst_DATA = array_zip.oct cell_cat.oct isfunctionhandle.oct \
	      last_downfall.oct matrix_rankize.oct parse_qps.oct \
	      quadprog_turlach.oct
EXTRA_DATA  = in_convex_hull.oct istream_open.oct psi.oct quadprog_cgal.oct \
	      regex_match.oct


# Generic
.cc.oct:
	$(MKOCTFILE) $(CPPFLAGS) $($*_OCTFLAGS) $(DEFS) $^ $($*_SOURCES) $(LDFLAGS) $($*_LDADD)


# in_convex_hull
if IN_CONVEX_HULL_MODULE
noinst_DATA += in_convex_hull.oct
in_convex_hull_LDADD = -lCGAL
in_convex_hull_CXXFLAGS = -g -frounding-math -Wall -Wextra -fPIC

in_convex_hull.oct: in_convex_hull.cc $(in_convex_hull_SOURCES)
	CXXFLAGS="$(in_convex_hull_CXXFLAGS)" $(MKOCTFILE) $(CPPFLAGS) $(in_convex_hull_OCTFLAGS) $(DEFS) $^ $(LDFLAGS) $(in_convex_hull_LDADD)
endif


# istream
if ISTREAM_MODULE
noinst_DATA  += istream_open.oct
istream_open_LDADD = -lttcl -lbz2 -lz
istream_open_CPPFLAGS = -DUSE_OCTAVE_ALLOCATOR

istream_open.oct: istream_open.cc
	$(MKOCTFILE) $(istream_open_CPPFLAGS) $(CPPFLAGS) $(istream_open_OCTFLAGS) $(DEFS) $^ $(LDFLAGS) $(istream_open_LDADD)
endif


# psi
if PSI_MODULE
noinst_DATA += psi.oct
psi_LDADD = -lRmath
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


# quadprog_turlach
quadprog_turlach_SOURCES = extern/linpack_dpofa.f extern/qpgen2.f \
			   extern/qpgen2_util.f quadprog_common.cc


# regex
if REGEX_MODULE
noinst_DATA += regex_match.oct
regex_match_LDADD  = -lboost_regex
endif
