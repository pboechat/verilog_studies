IVERILOG = iverilog
VVP = vvp
SRC_DIR = src
BUILD_DIR = build

VS = $(shell find $(SRC_DIR) -name '*.v')
VVPS = $(patsubst $(SRC_DIR)/%.v, $(BUILD_DIR)/%.vvp, $(VS))

all: $(VVPS)

# build rtls
$(BUILD_DIR)/rtl/%.vvp: $(SRC_DIR)/rtl/%.v
	@echo "Building $<..."
	@mkdir -p $(dir $@)
	$(IVERILOG) -I $(dir $<) -o $@ $<

# build tbs
$(BUILD_DIR)/tb/%.vvp: $(SRC_DIR)/tb/%.v
	@echo "Building $<..."
	@mkdir -p $(dir $@)
	$(IVERILOG) -I $(dir $(patsubst $(SRC_DIR)/tb/%.v, $(SRC_DIR)/rtl/%.v, $<)) -o $@ $<

clean:
	@echo "Cleaning up..."
	rm -rf $(BUILD_DIR)

.PHONY: all clean
