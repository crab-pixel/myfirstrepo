# VGA DVD Bouncer

VGA DVD Bouncer is a tiny video demo made for ASIC Hack Club.

Connect it to a VGA display to see a colour-bar test pattern, useful for
checking that the screen and wiring are working. Switch to demo mode to watch a
bright block bounce around the screen like the classic DVD screensaver.

The design is written in Verilog and fits on a Tiny Tapeout tile.

## Progress log

### 2026-11-08 — VGA bouncer testbench

Added `tb_dvd`, a simulation testbench for the bouncing box. It uses a large
620×460 box so the box only has 20 pixels of travel on each axis. The test
checks that the box stays inside the visible 640×480 area, reaches both far
edges, and returns to the origin after bouncing.

### 2026-11-08 — VGA colour-bar pixel dump

Added `tb_dump`, a testbench for the `vga_bars` module. It runs from a 25 MHz
pixel clock and writes three frames of `vsync_n`, red, green, and blue values
to `pixels.txt`. This data can be used to inspect the generated colour bars
outside the simulator.
