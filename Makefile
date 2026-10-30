#   make sim <module>   iverilog+vvp run of <module>_tb.v against <module>.v
#   make lint <module>  verilator --lint-only on <module>.v
#   make wave <module>  sim with waveform dump, open gtkwave on wave.vcd
#   make test           sim + lint every module (regFile, ALU, memory, decode, top)
#   make tools          just check the binaries are present and executable
#   make clean
#
# <module> is one of: regFile, ALU, memory, decode, top

TOOLS ?= ../software/bin

IVERILOG  ?= $(TOOLS)/iverilog
VVP       ?= $(TOOLS)/vvp
VERILATOR ?= $(TOOLS)/verilator
GTKWAVE   ?= $(TOOLS)/gtkwave

MODULES := regFile ALU memory decode top

# top.v instantiates regFile, memory, decode, and ALU, so it needs them compiled alongside it.
SRC_regFile := regFile.v
SRC_ALU     := ALU.v
SRC_memory  := memory.v
SRC_decode  := decode.v
SRC_top     := top.v regFile.v ALU.v memory.v decode.v

MODULE := $(word 2,$(MAKECMDGOALS))
RTL    := $(SRC_$(MODULE))
TB     := $(MODULE)_tb.v
TOP    := $(MODULE)_tb

IVFLAGS  ?= -g2012 -Wall
VLTFLAGS ?= --lint-only -Wall

BUILD := build

.PHONY: help test sim lint wave tools clean $(MODULES)
help:
	@sed -n '2,10p' $(MAKEFILE_LIST)

# Swallow the module name (e.g. "regFile" in "make sim regFile") so make
# doesn't also try to build it as a target of its own.
$(MODULES):
	@:

tools:
	@ok=1; for t in "$(IVERILOG)" "$(VVP)" "$(VERILATOR)"; do \
	  if [ -x "$$t" ]; then echo "  found   $$t"; \
	  else echo "  MISSING $$t"; ok=0; fi; \
	done; \
	if [ -x "$(GTKWAVE)" ]; then echo "  found   $(GTKWAVE)"; \
	else echo "  (gtkwave not found -- only needed for 'make wave')"; fi; \
	[ $$ok -eq 1 ] || { echo "toolchain incomplete"; exit 1; }

sim: tools
	@if [ -z "$(MODULE)" ] || [ -z "$(RTL)" ]; then \
	  echo "Usage: make sim <module>   where <module> is one of: $(MODULES)"; exit 1; \
	fi
	@mkdir -p $(BUILD)
	$(IVERILOG) $(IVFLAGS) -o $(BUILD)/$(TOP).vvp $(RTL) $(TB)
	$(VVP) $(BUILD)/$(TOP).vvp

lint: tools
	@if [ -z "$(MODULE)" ] || [ -z "$(RTL)" ]; then \
	  echo "Usage: make lint <module>   where <module> is one of: $(MODULES)"; exit 1; \
	fi
	$(VERILATOR) $(VLTFLAGS) --top-module $(MODULE) $(RTL)

wave: sim
	-$(GTKWAVE) wave.vcd >/dev/null 2>&1 &

test:
	@for m in $(MODULES); do \
	  echo "=== $$m ==="; \
	  $(MAKE) --no-print-directory sim $$m || exit 1; \
	  $(MAKE) --no-print-directory lint $$m || exit 1; \
	done
	@echo
	@echo "=== all modules PASSED: sim + lint for $(MODULES) ==="

clean:
	rm -rf $(BUILD) wave.vcd
