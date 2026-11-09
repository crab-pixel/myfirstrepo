module dvd_bounce #(
    parameter BOX_WIDTH  = 64,
    parameter BOX_HEIGHT = 32
)(
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
        .video_active (),
        .pixel_x      (pixel_x),
        .pixel_y      (pixel_y)
    );

    // Furthest the top-left corner of the box can go
    localparam MAX_BOX_X = 640 - BOX_WIDTH;
    localparam MAX_BOX_Y = 480 - BOX_HEIGHT;

    // One-clock pulse once per frame, at the start of vertical blanking
    wire frame_tick = (pixel_x == 10'd0) && (pixel_y == 10'd480);

    reg [9:0] box_x, box_y;
    reg       moving_right, moving_down;
    reg [1:0] color_index;

    wire [9:0] next_box_x = moving_right ? box_x + 10'd1 : box_x - 10'd1;
    wire [9:0] next_box_y = moving_down  ? box_y + 10'd1 : box_y - 10'd1;

    wire bounce_x = (next_box_x == MAX_BOX_X) || (next_box_x == 10'd0);
    wire bounce_y = (next_box_y == MAX_BOX_Y) || (next_box_y == 10'd0);

    always @(posedge pixel_clk) begin
        if (!reset_n) begin
            box_x        <= 10'd0;
            box_y        <= 10'd0;
            moving_right <= 1'b1;
            moving_down  <= 1'b1;
            color_index  <= 2'd0;
        end else if (frame_tick) begin
            box_x <= next_box_x;
            box_y <= next_box_y;

            if (next_box_x == MAX_BOX_X)      moving_right <= 1'b0;
            else if (next_box_x == 10'd0)     moving_right <= 1'b1;

            if (next_box_y == MAX_BOX_Y)      moving_down <= 1'b0;
            else if (next_box_y == 10'd0)     moving_down <= 1'b1;

            if (bounce_x || bounce_y)         color_index <= color_index + 2'd1;
        end
    end

    // The box never leaves the visible area, so no separate "visible" check is needed
    wire pixel_inside_box = (pixel_x >= box_x) && (pixel_x < box_x + BOX_WIDTH) &&
                            (pixel_y >= box_y) && (pixel_y < box_y + BOX_HEIGHT);

    // Pixel coordinates relative to the 64x32 logo box.
    wire [9:0] logo_pixel_x = pixel_x - box_x;
    wire [9:0] logo_pixel_y = pixel_y - box_y;

    // Three thick, geometric letters: D V D. The coloured box is the logo
    // background and these pixels are drawn in black on top of it.
    wire is_left_d_pixel =
        ((logo_pixel_x >= 10'd4)  && (logo_pixel_x <= 10'd6)  &&
         (logo_pixel_y >= 10'd7)  && (logo_pixel_y <= 10'd24)) ||
        ((logo_pixel_x >= 10'd7)  && (logo_pixel_x <= 10'd14) &&
         (((logo_pixel_y >= 10'd7) && (logo_pixel_y <= 10'd9)) ||
          ((logo_pixel_y >= 10'd22) && (logo_pixel_y <= 10'd24)))) ||
        ((logo_pixel_x >= 10'd15) && (logo_pixel_x <= 10'd17) &&
         (logo_pixel_y >= 10'd10) && (logo_pixel_y <= 10'd21));

    wire [9:0] v_stroke_offset = (logo_pixel_y - 10'd7) >> 1;
    wire [9:0] v_left_stroke_x = 10'd22 + v_stroke_offset;
    wire [9:0] v_right_stroke_x = 10'd42 - v_stroke_offset;
    wire is_v_pixel = (logo_pixel_y >= 10'd7) && (logo_pixel_y <= 10'd24) &&
        (((logo_pixel_x >= v_left_stroke_x) &&
          (logo_pixel_x < v_left_stroke_x + 10'd3)) ||
         ((logo_pixel_x > v_right_stroke_x - 10'd3) &&
          (logo_pixel_x <= v_right_stroke_x)));

    wire is_right_d_pixel =
        ((logo_pixel_x >= 10'd47) && (logo_pixel_x <= 10'd49) &&
         (logo_pixel_y >= 10'd7)  && (logo_pixel_y <= 10'd24)) ||
        ((logo_pixel_x >= 10'd50) && (logo_pixel_x <= 10'd57) &&
         (((logo_pixel_y >= 10'd7) && (logo_pixel_y <= 10'd9)) ||
          ((logo_pixel_y >= 10'd22) && (logo_pixel_y <= 10'd24)))) ||
        ((logo_pixel_x >= 10'd58) && (logo_pixel_x <= 10'd60) &&
         (logo_pixel_y >= 10'd10) && (logo_pixel_y <= 10'd21));

    // Stepped arcs above and below the letters make the small mark read more
    // like the familiar DVD screensaver logo without needing a font ROM.
    wire is_top_swoosh_pixel =
        ((logo_pixel_x >= 10'd18) && (logo_pixel_x <= 10'd46) &&
         (logo_pixel_y >= 10'd2)  && (logo_pixel_y <= 10'd3)) ||
        ((((logo_pixel_x >= 10'd13) && (logo_pixel_x <= 10'd17)) ||
          ((logo_pixel_x >= 10'd47) && (logo_pixel_x <= 10'd51))) &&
         (logo_pixel_y >= 10'd3) && (logo_pixel_y <= 10'd4)) ||
        ((((logo_pixel_x >= 10'd9) && (logo_pixel_x <= 10'd12)) ||
          ((logo_pixel_x >= 10'd52) && (logo_pixel_x <= 10'd55))) &&
         (logo_pixel_y >= 10'd5) && (logo_pixel_y <= 10'd6));

    wire is_bottom_swoosh_pixel =
        ((logo_pixel_x >= 10'd23) && (logo_pixel_x <= 10'd41) &&
         (logo_pixel_y >= 10'd28) && (logo_pixel_y <= 10'd29)) ||
        ((((logo_pixel_x >= 10'd17) && (logo_pixel_x <= 10'd22)) ||
          ((logo_pixel_x >= 10'd42) && (logo_pixel_x <= 10'd47))) &&
         (logo_pixel_y >= 10'd27) && (logo_pixel_y <= 10'd28)) ||
        ((((logo_pixel_x >= 10'd12) && (logo_pixel_x <= 10'd16)) ||
          ((logo_pixel_x >= 10'd48) && (logo_pixel_x <= 10'd52))) &&
         (logo_pixel_y >= 10'd25) && (logo_pixel_y <= 10'd26));

    wire is_dvd_logo_pixel = is_left_d_pixel || is_v_pixel || is_right_d_pixel ||
                              is_top_swoosh_pixel || is_bottom_swoosh_pixel;

    // Registered so it lines up with the registered sync outputs
    always @(posedge pixel_clk) begin
        if (!reset_n || !pixel_inside_box || is_dvd_logo_pixel) begin
            {red, green, blue} <= 6'd0;
        end else begin
            case (color_index)
                2'd0:    {red, green, blue} <= {2'b11, 2'b11, 2'b11};  // white
                2'd1:    {red, green, blue} <= {2'b11, 2'b11, 2'b00};  // yellow
                2'd2:    {red, green, blue} <= {2'b00, 2'b11, 2'b11};  // cyan
                default: {red, green, blue} <= {2'b11, 2'b00, 2'b11};  // magenta
            endcase
        end
    end
endmodule
