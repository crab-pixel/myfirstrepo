# DVD Bounce VGA

A 640×480 VGA DVD-style screensaver built in Verilog for a one-tile Tiny
Tapeout GF180 submission. The 128×64 logo moves two pixels each frame, bounces
at the screen edges, and changes colour on a bounce.

The project follows the [Tiny Tapeout GF180 Verilog template](https://github.com/TinyTapeout/ttgf-verilog-template):

- `src/` contains synthesizable RTL and LibreLane configuration.
- `info.yaml` declares the project, top module, pins, and source files.
- `test/` contains the cocotb RTL / gate-level test setup.
- `docs/info.md` supplies the generated datasheet content.
- `.github/workflows/` runs test, GDS, precheck, viewer, docs, and FPGA workflows.

## Local checks

Run a dependency-free compile/simulation smoke check:

```sh
make smoke
```

For the cocotb test, install `test/requirements.txt`, then run:

```sh
make test
```

See [the project datasheet](docs/info.md) for implementation and hardware
details.
