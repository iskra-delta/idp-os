# Folders
SUBDIRS = rom

# Rules.
.PHONY: all clean
all:	$(SUBDIRS) 

.PHONY: $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@
	
clean: