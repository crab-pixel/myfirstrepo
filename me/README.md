# My VGA DVD Bouncer

This folder is my workspace for writing and testing my own ASIC Hack Club
submission.

The project will generate a VGA test pattern and a DVD-style bouncing logo.

## Progress

- Added a 640×480 VGA sync generator for a 25.175 MHz pixel clock.
- The generator provides `pixel_x`, `pixel_y`, `video_active`, `hsync_n`, and
  `vsync_n` to the rest of the design.
- Added a five-bar VGA colour-pattern generator for validating the RGB outputs.
- Added a timing testbench that checks HSYNC pulse width and line period, plus
  VSYNC pulse width and frame period.
- Replaced the plain bouncing rectangle with a coloured, DVD-style wordmark
  and swooshes drawn directly from pixel-coordinate comparisons.
