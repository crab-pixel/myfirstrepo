`timescale 1ns/1ps

module tb_vga;
    reg  pixel_clk = 0;
    reg  reset_n   = 0;
    wire hsync_n, vsync_n;
    wire [1:0] red, green, blue;

    vga_bars device_under_test (
        .pixel_clk (pixel_clk),
        .reset_n   (reset_n),
        .hsync_n   (hsync_n),
        .vsync_n   (vsync_n),
        .red       (red), .green (green), .blue (blue)
    );

    always #19.861 pixel_clk = ~pixel_clk;   // 39.722 ns period = 25.175 MHz

    integer clock_cycle_count         = 0;
    integer cycle_of_last_hsync_start = -1;
    integer cycle_of_last_vsync_start = -1;
    integer hsync_low_cycles          = 0;
    integer vsync_low_cycles          = 0;
    integer error_count               = 0;

    reg hsync_n_previous = 1;
    reg vsync_n_previous = 1;

    always @(posedge pixel_clk) if (reset_n) begin
        clock_cycle_count <= clock_cycle_count + 1;
        hsync_n_previous  <= hsync_n;
        vsync_n_previous  <= vsync_n;

        if (!hsync_n) hsync_low_cycles <= hsync_low_cycles + 1;
        if (!vsync_n) vsync_low_cycles <= vsync_low_cycles + 1;

        // hsync falling edge: check line period (800 clocks)
        if (hsync_n_previous && !hsync_n) begin
            if (cycle_of_last_hsync_start >= 0 &&
                (clock_cycle_count - cycle_of_last_hsync_start) != 800) begin
                $display("FAIL: line period %0d, expected 800",
                         clock_cycle_count - cycle_of_last_hsync_start);
                error_count = error_count + 1;
            end
            cycle_of_last_hsync_start <= clock_cycle_count;
            hsync_low_cycles          <= 1;
        end

        // hsync rising edge: check pulse width (96 clocks)
        if (!hsync_n_previous && hsync_n && hsync_low_cycles != 96) begin
            $display("FAIL: hsync width %0d, expected 96", hsync_low_cycles);
            error_count = error_count + 1;
        end

        // vsync falling edge: check frame period (800 * 525 clocks)
        if (vsync_n_previous && !vsync_n) begin
            if (cycle_of_last_vsync_start >= 0 &&
                (clock_cycle_count - cycle_of_last_vsync_start) != 800 * 525) begin
                $display("FAIL: frame period %0d, expected %0d",
                         clock_cycle_count - cycle_of_last_vsync_start, 800 * 525);
                error_count = error_count + 1;
            end
            cycle_of_last_vsync_start <= clock_cycle_count;
            vsync_low_cycles          <= 1;
        end

        // vsync rising edge: check pulse width (2 lines = 1600 clocks)
        if (!vsync_n_previous && vsync_n && vsync_low_cycles != 2 * 800) begin
            $display("FAIL: vsync width %0d, expected %0d", vsync_low_cycles, 2 * 800);
            error_count = error_count + 1;
        end
    end

    initial begin
        $dumpfile("vga.vcd");
        $dumpvars(0, tb_vga);

        #100 reset_n = 1;
        #(39.722 * 800 * 525 * 3 + 1000);    // run about 3 frames

        if (error_count == 0) $display("PASS");
        else                  $display("%0d errors", error_count);
        $finish;
    end
endmodule
