# SUBDIRS
SUBDIRS = @Dirichlet/private    @JSDivergence/private \
	  @KLDivergence/private @KMDMultinomial/private \
	  @LogisticLoss/private @MahalanobisDistance/private \
	  @SmoothKLDivergence/private

# Modules
MODULES = affinity CPM3C multi_assignment read_redo read_seeds read_sparse

# Module specific libs
read_redo_LIBS            = -lttcl -lbz2 -lz -lboost_regex
read_seeds_LIBS           = -lttcl -lbz2 -lz -lboost_regex
read_sparse_LIBS          = -lttcl -lbz2 -lz

# Include
include make/ModuleMakefile.inc
