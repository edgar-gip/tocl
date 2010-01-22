# Paths
MKOCTFILE = mkoctfile

# Flags
OCTFLAGS = -Wall -Wextra

# Modules
MODULES = istream

# Module specific flags
# <module>_OCTFLAGS = ...
istream_OCTFLAGS = -I../include -I../../ttcl-0.3/include

# Module specific libs
# <module>_LIBS = ...
istream_LIBS = -lbz2 -lz

# Objects and targets
OBJECTS = $(addsuffix .o,   $(MODULES))
TARGETS = $(addsuffix .oct, $(MODULES))

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
