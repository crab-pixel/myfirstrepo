## How it works

The design generates standard 640x480 VGA timing from a 25.175 MHz pixel
clock. A 128x64 pixel DVD-style mark moves two pixels per frame and reverses at
the display edges. Its colour changes after each bounce. The logo and its
lettering are generated directly from pixel-coordinate comparisons, so no
framebuffer or font ROM is required.

`uo_out` uses the TinyVGA PMOD bit order: `HSYNC, B0, G0, R0, VSYNC, B1, G1,
R1`. HSYNC and VSYNC are active low; the RGB channels are two bits each.

## How to test

Apply a 25.175 MHz clock to `clk`, hold `rst_n` low for at least one clock,
then release it. The cocotb test checks the reset state, unused bidirectional
pins, and one 800-pixel horizontal timing period with its 96-cycle sync pulse.

Run the RTL test locally with:

```sh
cd test
make
```

## External hardware

A TinyVGA-compatible resistor-DAC PMOD and a VGA monitor are required to view
the output.
