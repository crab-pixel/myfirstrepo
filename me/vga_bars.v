module vga_bars (
    input  wire       pixel_clk,
    input  wire       reset_n,
    output wire       hsync_n,
    output wire       vsync_n,
    output reg  [1:0] red,
    output reg  [1:0] green,
    output reg  [1:0] blue
);
    wire [9:0] pixel_x, pixel_y;

    vga_sync sync_generator (
        .pixel_clk    (pixel_clk),
        .reset_n      (reset_n),
        .hsync_n      (hsync_n),
        .vsync_n      (vsync_n),
        .video_active (),               // unused here, left unconnected
        .pixel_x      (pixel_x),
        .pixel_y      (pixel_y)
    );

    wire inside_visible_area = (pixel_x < 640) && (pixel_y < 480);

    // Each bar is 128 pixels wide, so pixel_x[9:7] is the bar number 0..4
    wire [2:0] bar_index = pixel_x[9:7];

    always @(posedge pixel_clk) begin
        if (!reset_n || !inside_visible_area) begin
            {red, green, blue} <= 6'd0;   // black outside the picture
        end else begin
            case (bar_index)
                3'd0:    {red, green, blue} <= {2'b11, 2'b11, 2'b11};  // white
                3'd1:    {red, green, blue} <= {2'b11, 2'b11, 2'b00};  // yellow
                3'd2:    {red, green, blue} <= {2'b00, 2'b11, 2'b11};  // cyan
                3'd3:    {red, green, blue} <= {2'b00, 2'b11, 2'b00};  // green
                default: {red, green, blue} <= {2'b11, 2'b00, 2'b11};  // magenta
            endcase
        end
    end
endmodule
