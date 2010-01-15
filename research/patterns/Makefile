# Paths
MKOCTFILE = mkoctfile

# Flags
OCTFLAGS = -Wall -Wextra

# Modules
MODULES = CPM3C read_redo read_sparse

# Module specific flags
# <module>_OCTFLAGS = ...
CPM3C_OCTFLAGS       = -I$(HOME)/devel/libs/ttcl-0.3/include
read_redo_OCTFLAGS   = -I$(HOME)/devel/libs/ttcl-0.3/include
read_sparse_OCTFLAGS = -I$(HOME)/devel/libs/ttcl-0.3/include

# Module specific libs
# <module>_LIBS = ...
read_redo_LIBS   = -lbz2 -lz -lboost_regex
read_sparse_LIBS = -lbz2 -lz

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
