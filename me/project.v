`default_nettype none

module tt_um_crabby605_dvd (
    input  wire [7:0] ui_in,    // dedicated inputs, unused
    output wire [7:0] uo_out,   // dedicated outputs, VGA
    input  wire [7:0] uio_in,   // bidirectional, unused
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,      // always 1 when powered
    input  wire       clk,      // VGA pixel clock
    input  wire       rst_n     // active low reset
);
    wire       hsync_n, vsync_n;
    wire [1:0] red, green, blue;

    dvd_bounce dvd (
        .pixel_clk (clk),
        .reset_n   (rst_n),
        .hsync_n   (hsync_n),
        .vsync_n   (vsync_n),
        .red       (red),
        .green     (green),
        .blue      (blue)
    );

    // TinyVGA PMOD order, bit 7 down to bit 0:
    // hsync, B0, G0, R0, vsync, B1, G1, R1
    assign uo_out  = {hsync_n, blue[0], green[0], red[0],
                      vsync_n, blue[1], green[1], red[1]};

    assign uio_out = 8'h00;
    assign uio_oe  = 8'h00;   // all bidirectional pins are inputs

    wire _unused = &{ena, ui_in, uio_in, 1'b0};
endmodule
