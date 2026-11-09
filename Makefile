.PHONY: test smoke lint

# Full cocotb RTL test (requires the packages in test/requirements.txt).
test:
	cd test && $(MAKE)

# Dependency-free compile/simulation check for quick local validation.
smoke:
	iverilog -g2012 -s tb -o /tmp/dvd_vga_tb src/project.v src/dvd_bounce.v src/vga_sync.v test/tb.v
	vvp /tmp/dvd_vga_tb

lint:
	verilator --lint-only -Wall -Wno-fatal src/project.v src/dvd_bounce.v src/vga_sync.v
