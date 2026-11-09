`default_nettype none
module dvd_bounce #(
    // The logo geometry below is authored on a 64x32 grid and rendered 2x.
    parameter BOX_WIDTH = 128, parameter BOX_HEIGHT = 64, parameter STEP = 2
) (
    input wire pixel_clk, input wire reset_n, output wire hsync_n,
    output wire vsync_n, output reg [1:0] red, output reg [1:0] green,
    output reg [1:0] blue
);
    wire [9:0] pixel_x, pixel_y;
    wire video_active;

    vga_sync sync_generator (
        .pixel_clk(pixel_clk), .reset_n(reset_n), .hsync_n(hsync_n),
        .vsync_n(vsync_n), .video_active(video_active),
        .pixel_x(pixel_x), .pixel_y(pixel_y)
    );
    localparam MAX_BOX_X = 640 - BOX_WIDTH;
    localparam MAX_BOX_Y = 480 - BOX_HEIGHT;
    wire frame_tick = (pixel_x == 0) && (pixel_y == 480);
    reg [9:0] box_x, box_y;
    reg moving_right, moving_down;
    reg [1:0] color_index;
    wire [9:0] next_box_x = moving_right ? box_x + STEP : box_x - STEP;
    wire [9:0] next_box_y = moving_down ? box_y + STEP : box_y - STEP;
    wire bounce_x = (next_box_x == MAX_BOX_X) || (next_box_x == 0);
    wire bounce_y = (next_box_y == MAX_BOX_Y) || (next_box_y == 0);
    always @(posedge pixel_clk) begin
        if (!reset_n) begin
            box_x <= 256; box_y <= 208; moving_right <= 1; moving_down <= 1; color_index <= 0;
        end else if (frame_tick) begin
            box_x <= next_box_x; box_y <= next_box_y;
            if (next_box_x == MAX_BOX_X) moving_right <= 0;
            else if (next_box_x == 0) moving_right <= 1;
            if (next_box_y == MAX_BOX_Y) moving_down <= 0;
            else if (next_box_y == 0) moving_down <= 1;
            if (bounce_x || bounce_y) color_index <= color_index + 1'b1;
        end
    end
    wire pixel_inside_box = (pixel_x >= box_x) && (pixel_x < box_x + BOX_WIDTH) &&
                            (pixel_y >= box_y) && (pixel_y < box_y + BOX_HEIGHT);
    wire [9:0] logo_pixel_x = (pixel_x - box_x) >> 1;
    wire [9:0] logo_pixel_y = (pixel_y - box_y) >> 1;
    wire is_left_d_pixel =
        ((logo_pixel_x >= 4) && (logo_pixel_x <= 6) && (logo_pixel_y >= 7) && (logo_pixel_y <= 24)) ||
        ((logo_pixel_x >= 7) && (logo_pixel_x <= 14) && (((logo_pixel_y >= 7) && (logo_pixel_y <= 9)) || ((logo_pixel_y >= 22) && (logo_pixel_y <= 24)))) ||
        ((logo_pixel_x >= 15) && (logo_pixel_x <= 17) && (logo_pixel_y >= 10) && (logo_pixel_y <= 21));
    wire [9:0] v_stroke_offset = (logo_pixel_y - 7) >> 1;
    wire [9:0] v_left_stroke_x = 22 + v_stroke_offset;
    wire [9:0] v_right_stroke_x = 42 - v_stroke_offset;
    wire is_v_pixel = (logo_pixel_y >= 7) && (logo_pixel_y <= 24) &&
        (((logo_pixel_x >= v_left_stroke_x) && (logo_pixel_x < v_left_stroke_x + 3)) || ((logo_pixel_x > v_right_stroke_x - 3) && (logo_pixel_x <= v_right_stroke_x)));
    wire is_right_d_pixel =
        ((logo_pixel_x >= 47) && (logo_pixel_x <= 49) && (logo_pixel_y >= 7) && (logo_pixel_y <= 24)) ||
        ((logo_pixel_x >= 50) && (logo_pixel_x <= 57) && (((logo_pixel_y >= 7) && (logo_pixel_y <= 9)) || ((logo_pixel_y >= 22) && (logo_pixel_y <= 24)))) ||
        ((logo_pixel_x >= 58) && (logo_pixel_x <= 60) && (logo_pixel_y >= 10) && (logo_pixel_y <= 21));
    wire is_top_swoosh_pixel =
        ((logo_pixel_x >= 18) && (logo_pixel_x <= 46) && (logo_pixel_y >= 2) && (logo_pixel_y <= 3)) ||
        ((((logo_pixel_x >= 13) && (logo_pixel_x <= 17)) || ((logo_pixel_x >= 47) && (logo_pixel_x <= 51))) && (logo_pixel_y >= 3) && (logo_pixel_y <= 4)) ||
        ((((logo_pixel_x >= 9) && (logo_pixel_x <= 12)) || ((logo_pixel_x >= 52) && (logo_pixel_x <= 55))) && (logo_pixel_y >= 5) && (logo_pixel_y <= 6));
    wire is_dvd_logo_pixel = is_left_d_pixel || is_v_pixel || is_right_d_pixel || is_top_swoosh_pixel;
    always @(posedge pixel_clk) begin
        // Explicitly blank during the VGA porch/sync intervals, even if the
        // logo geometry or timing constants are changed in the future.
        if (!reset_n || !video_active || !pixel_inside_box || !is_dvd_logo_pixel)
            {red, green, blue} <= 0;
        else case (color_index)
            0: {red, green, blue} <= 6'b001100;
            1: {red, green, blue} <= 6'b001111;
            2: {red, green, blue} <= 6'b111100;
            default: {red, green, blue} <= 6'b110011;
        endcase
    end
endmodule
`default_nettype wire
