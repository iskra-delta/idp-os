# Tools.
AS = sdasz80
AS_FLAGS = -l
LD = sdldz80
LD_FLAGS = -iy
OBJCOPY = sdobjcopy
OBJCOPY_FLAGS = -I ihex -O binary 
COPY = cp

# Folders.
SRC_DIR = $(realpath .)

# Assembler files.
HEAD = $(SRC_DIR)/head.s
SRC_FILES = $(filter-out $(SRC_DIR)/head.s, $(wildcard $(SRC_DIR)/*.s))
REL_FILES = $(BUILD_DIR)/head.rel $(patsubst $(SRC_DIR)/%.s,$(BUILD_DIR)/%.rel,$(SRC_FILES))

TARGET = partos

.PHONY:	all clean
all: $(BIN_DIR)/$(TARGET).rom

$(BIN_DIR)/$(TARGET).rom : $(BUILD_DIR)/$(TARGET).rom 
	$(COPY) $(BUILD_DIR)/$(TARGET).rom $(BIN_DIR)/$(TARGET).rom

$(BUILD_DIR)/$(TARGET).rom : $(BUILD_DIR)/$(TARGET).ihx
	$(OBJCOPY) $(OBJCOPY_FLAGS) $(BUILD_DIR)/$(TARGET).ihx $(BUILD_DIR)/$(TARGET).rom

$(BUILD_DIR)/$(TARGET).ihx: $(REL_FILES)
	$(LD) $(LD_FLAGS) -o $@ $(REL_FILES)

$(BUILD_DIR)/%.rel: $(SRC_DIR)/%.s
	$(AS) $(AS_FLAGS) -o $@ $<

clean: