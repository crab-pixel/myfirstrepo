`timescale 1ns/1ps

module tb_dvd;
    reg  pixel_clk = 0;
    reg  reset_n   = 0;
    wire hsync_n, vsync_n;
    wire [1:0] red, green, blue;

    localparam RANGE = 20;   // 640 - 620 and 480 - 460

    dvd_bounce #(.BOX_WIDTH(620), .BOX_HEIGHT(460)) device_under_test (
        .pixel_clk (pixel_clk), .reset_n (reset_n),
        .hsync_n (hsync_n), .vsync_n (vsync_n),
        .red (red), .green (green), .blue (blue)
    );

    always #19.861 pixel_clk = ~pixel_clk;

    integer error_count = 0;
    integer max_x_seen = 0, max_y_seen = 0;
    reg x_reached_max = 0, x_returned = 0;
    reg y_reached_max = 0, y_returned = 0;

    always @(posedge pixel_clk) if (reset_n) begin
        if (device_under_test.box_x > RANGE || device_under_test.box_y > RANGE) begin
            $display("FAIL: box out of range x=%0d y=%0d",
                     device_under_test.box_x, device_under_test.box_y);
            error_count = error_count + 1;
        end
        if (device_under_test.box_x > max_x_seen) max_x_seen = device_under_test.box_x;
        if (device_under_test.box_y > max_y_seen) max_y_seen = device_under_test.box_y;

        if (device_under_test.box_x == RANGE) x_reached_max = 1;
        if (x_reached_max && device_under_test.box_x == 0) x_returned = 1;
        if (device_under_test.box_y == RANGE) y_reached_max = 1;
        if (y_reached_max && device_under_test.box_y == 0) y_returned = 1;
    end

    initial begin
        $dumpfile("dvd.vcd");
        $dumpvars(0, tb_dvd);
        #100 reset_n = 1;
        #(39.722 * 800 * 525 * 85);   // ~85 frames

        if (!(x_reached_max && x_returned && y_reached_max && y_returned)) begin
            $display("FAIL: did not bounce both ways on both axes");
            error_count = error_count + 1;
        end
        if (error_count == 0) $display("PASS (max x=%0d, max y=%0d)", max_x_seen, max_y_seen);
        else                  $display("%0d errors", error_count);
        $finish;
    end
endmodule
