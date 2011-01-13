# -*- mode: makefile; -*-

# Usage variables
# MODULES           : Modules
# <module>_OCTFLAGS : Module-specific flags
# <module>_LIBS     : Module-specific libs

# Paths
MKOCTFILE = mkoctfile

# Flags
OCTFLAGS = -Wall -Wextra

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
