# Paths
MKOCTFILE = mkoctfile

# Flags
OCTFLAGS = -Wall -Wextra

# Modules
MODULES = cell CPM3C read_redo read_sparse regex

# Module specific flags
CPM3C_OCTFLAGS       = -I$(HOME)/devel/libs/ttcl-0.3/include
read_redo_OCTFLAGS   = -I$(HOME)/devel/libs/ttcl-0.3/include
read_sparse_OCTFLAGS = -I$(HOME)/devel/libs/ttcl-0.3/include

# Module specific libs
read_redo_LIBS       = -lbz2 -lz
read_sparse_LIBS     = -lbz2 -lz
regex_LIBS           = -lboost_regex

# Objects and targets
OBJECTS = $(addsuffix .o,   $(MODULES))
TARGETS = $(addsuffix .oct, $(MODULES))

# Modules 

# All targets
all: $(TARGETS)


# .oct file generation
%.oct: %.cc
	$(MKOCTFILE) $($*_OCTFLAGS) $^ $($*_LIBS)


# Clean targets
clean:
	rm -f $(OBJECTS)

distclean: clean
	rm -f $(TARGETS)
