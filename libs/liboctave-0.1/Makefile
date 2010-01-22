# Subdirs
SUBDIRS = base io tests

# Target
all: subdirs

# Generic subdir rule template
define SUBDIR_RULE_TEMPLATE
$(1)_$(2):
	$$(MAKE) -C $(1) $(3)

endef

# Generic rule template
define PHONY_RULE_TEMPLATE
.PHONY: $(1)
$(1): $(addsuffix _$(1),$(SUBDIRS))
$(foreach dir,$(SUBDIRS),$(eval $(call SUBDIR_RULE_TEMPLATE,$(dir),$(1),$(2))))
endef

# Subdirs pattern
$(eval $(call PHONY_RULE_TEMPLATE,subdirs,))

# Clean targets
$(eval $(call PHONY_RULE_TEMPLATE,clean,clean))

$(eval $(call PHONY_RULE_TEMPLATE,distclean,distclean))
