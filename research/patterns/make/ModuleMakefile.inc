# -*- mode: makefile; -*-

# Usage variables
# MODULES           : Modules
# <module>_OCTFLAGS : Module-specific flags
# <module>_LIBS     : Module-specific libs
# SUBDIRS           : Subdirectories

# Paths
MKOCTFILE = mkoctfile

# Flags
OCTFLAGS = -Wall -Wextra

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
	$(MKOCTFILE) $($*_OCTFLAGS) $^ $($*_LIBS)

# Subdirs
$(foreach s,$(SUBDIRS),$(eval $(call SUBDIR_TEMPLATE,$(s))))

# Clean targets
clean:
	rm -f $(OBJECTS)

distclean: clean
	rm -f $(TARGETS)
