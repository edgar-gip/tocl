# Paths
MKOCTFILE = mkoctfile

# Flags
OCTFLAGS = -Wall -Wextra

# Modules
MODULES = mahalanobis_distance1

# Module specific flags
# <module>_OCTFLAGS = ...

# Module specific libs
# <module>_LIBS = ...

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
