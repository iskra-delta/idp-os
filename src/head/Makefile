# Tools.
AS = sdasz80
AS_FLAGS = -l
LD = sdldz80
LD_FLAGS = -iy
OBJCOPY = sdobjcopy
OBJCOPY_FLAGS = -I ihex -O binary 

# Folders.
SRC_DIR = $(realpath .)

# Assembler files.
CRT0 = head
SRC_FILES = $(filter-out $(SRC_DIR)/$(CRT0).s, $(wildcard $(SRC_DIR)/*.s))
REL_FILES = $(BUILD_DIR)/$(CRT0).rel $(patsubst $(SRC_DIR)/%.s,$(BUILD_DIR)/%.rel,$(SRC_FILES))

TARGET = head

.PHONY:	all clean
all: $(BUILD_DIR)/$(TARGET).bin

$(BUILD_DIR)/$(TARGET).bin : $(BUILD_DIR)/$(TARGET).ihx
	$(OBJCOPY) $(OBJCOPY_FLAGS) $< $@

$(BUILD_DIR)/$(TARGET).ihx: $(REL_FILES)
	$(LD) $(LD_FLAGS) -o $@ $(REL_FILES)

$(BUILD_DIR)/%.rel: $(SRC_DIR)/%.s
	$(AS) $(AS_FLAGS) -o $@ $<

clean: