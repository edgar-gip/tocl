# Paths
MKOCTFILE = mkoctfile

# Flags
OCTFLAGS = -Wall -Wextra

# SUBDIRS
SUBDIRS = @GaussianModel/private @MahalanobisDistance/private @Dirichlet/private

# Modules
MODULES = CPM3C read_redo read_seeds read_sparse

# Module specific flags
# <module>_OCTFLAGS = ...
CPM3C_OCTFLAGS       = -I../../../libs/ttcl-0.3/include
read_redo_OCTFLAGS   = -I../../../libs/ttcl-0.3/include
read_seeds_OCTFLAGS  = -I../../../libs/ttcl-0.3/include
read_sparse_OCTFLAGS = -I../../../libs/ttcl-0.3/include

# Module specific libs
# <module>_LIBS = ...
read_redo_LIBS            = -lbz2 -lz -lboost_regex
read_seeds_LIBS           = -lbz2 -lz -lboost_regex
read_sparse_LIBS          = -lbz2 -lz

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
.PHONY: all
all: $(TARGETS)

# .oct file generation
%.oct: %.cc
	$(MKOCTFILE) $($*_OCTFLAGS) $^ $($*_LIBS)

# Subdirs
$(foreach s,$(SUBDIRS),$(eval $(call SUBDIR_TEMPLATE,$(s))))

# Clean targets
clean: _clean
_clean:
	rm -f $(OBJECTS)

distclean: _clean
	rm -f $(TARGETS)
