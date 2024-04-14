# Tools.
TRUNC = truncate
TRUNC_FLAGS = -s 2K
CAT = cat

# Folders
SUBDIRS = ukernel head

# Target
TARGET = partos.rom
BIN_FILES = $(BUILD_DIR)/head.bin $(BUILD_DIR)/ukernel.bin

# Rules.
.PHONY: all clean
all:	$(SUBDIRS) glue

.PHONY: $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@
	
glue:
	$(CAT) $(BIN_FILES) > $(BIN_DIR)/$(TARGET)
	$(TRUNC) $(TRUNC_FLAGS) $(BIN_DIR)/$(TARGET)

clean: