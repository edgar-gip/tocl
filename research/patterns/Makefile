# SUBDIRS
SUBDIRS = @Dirichlet/private    @JSDivergence/private \
	  @KLDivergence/private @KMDMultinomial/private \
	  @LogisticLoss/private @MahalanobisDistance/private \
	  @SmoothKLDivergence/private

# Modules
MODULES = CPM3C multi_assignment read_redo read_seeds read_sparse

# Module specific flags
CPM3C_OCTFLAGS       = -I../../../libs/ttcl-0.3/include
read_redo_OCTFLAGS   = -I../../../libs/ttcl-0.3/include
read_seeds_OCTFLAGS  = -I../../../libs/ttcl-0.3/include
read_sparse_OCTFLAGS = -I../../../libs/ttcl-0.3/include

# Module specific libs
read_redo_LIBS            = -lbz2 -lz -lboost_regex
read_seeds_LIBS           = -lbz2 -lz -lboost_regex
read_sparse_LIBS          = -lbz2 -lz

# Include
include make/ModuleMakefile.inc
