`timescale 1ns/1ps

module tb_dump;
    reg  pixel_clk = 0;
    reg  reset_n   = 0;
    wire hsync_n, vsync_n;
    wire [1:0] red, green, blue;

    vga_bars device_under_test (
        .pixel_clk (pixel_clk),
        .reset_n   (reset_n),
        .hsync_n   (hsync_n),
        .vsync_n   (vsync_n),
        .red       (red),
        .green     (green),
        .blue      (blue)
    );

    always #19.861 pixel_clk = ~pixel_clk;   // 25.175 MHz

    integer output_file;

    // One line per clock: vsync_n red green blue
    always @(posedge pixel_clk) if (reset_n)
        $fwrite(output_file, "%0d %0d %0d %0d\n", vsync_n, red, green, blue);

    initial begin
        output_file = $fopen("pixels.txt", "w");
        #100 reset_n = 1;
        #(39.722 * 800 * 525 * 3);           // 3 frames, so one complete frame follows the first vsync
        $fclose(output_file);
        $finish;
    end
endmodule
