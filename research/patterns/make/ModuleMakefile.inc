# -*- mode: makefile; -*-

# Usage variables
# MODULES           : Modules
# <module>_OCTFLAGS : Module-specific flags
# <module>_LIBS     : Module-specific libs
# SUBDIRS           : Subdirectories

# Paths
MKOCTFILE = mkoctfile

# Octave version
OCTAVE_VERSION = \
  $(shell octave --version | head -n 1 | \
    sed -e 's/^.\+\([[:digit:]]\+\.[[:digit:]]\+\)\.[[:digit:]]\+$$/\1/')
OCTAVE_MAJOR = \
  $(shell echo "$(OCTAVE_VERSION)" | sed -e 's/\.[[:digit:]]\+$$//')
OCTAVE_MINOR = \
  $(shell echo "$(OCTAVE_VERSION)" | sed -e 's/^[[:digit:]]\+\.//')
OCTFLAGS_VER = -DOCTAVE_MAJOR=$(OCTAVE_MAJOR) -DOCTAVE_MINOR=$(OCTAVE_MINOR)

# Flags
OCTFLAGS = -Wall -Wextra $(OCTFLAGS_VER)

# Objects and targets
OBJECTS = $(addsuffix .o,   $(MODULES))
TARGETS = $(addsuffix .oct, $(MODULES))

# Subdirs template
define SUBDIR_TEMPLATE
all: all_$(1)
all_$(1):
	$$(MAKE) -C $(1) all

clean: clean_$(1)
clean_$(1):
	$$(MAKE) -C $(1) clean

distclean: distclean_$(1)
distclean_$(1):
	$$(MAKE) -C $(1) distclean
endef

# All targets
all: $(TARGETS)

# .oct file generation
%.oct: %.cc
	$(MKOCTFILE) $(OCTFLAGS) $($*_OCTFLAGS) $^ $($*_LIBS)

# Subdirs
$(foreach s,$(SUBDIRS),$(eval $(call SUBDIR_TEMPLATE,$(s))))

# Clean targets
clean:
	rm -f $(OBJECTS)

distclean: clean
	rm -f $(TARGETS)
