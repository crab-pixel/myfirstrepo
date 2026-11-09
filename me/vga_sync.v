module vga_sync (
    input  wire       pixel_clk,
    input  wire       reset_n,          // active low

    output reg        hsync_n,          // active low, registered
    output reg        vsync_n,          // active low, registered
    output reg        video_active,     // registered, high inside visible area

    output wire [9:0] pixel_x,          // counters, 1 cycle EARLIER than the registered outputs
    output wire [9:0] pixel_y
);
    // Horizontal timing, in pixel clocks
    localparam H_VISIBLE     = 640;
    localparam H_FRONT_PORCH = 16;
    localparam H_SYNC_PULSE  = 96;
    localparam H_TOTAL       = 800;
    localparam H_SYNC_START  = H_VISIBLE + H_FRONT_PORCH;     // 656
    localparam H_SYNC_END    = H_SYNC_START + H_SYNC_PULSE;   // 752

    // Vertical timing, in lines
    localparam V_VISIBLE     = 480;
    localparam V_FRONT_PORCH = 10;
    localparam V_SYNC_PULSE  = 2;
    localparam V_TOTAL       = 525;
    localparam V_SYNC_START  = V_VISIBLE + V_FRONT_PORCH;     // 490
    localparam V_SYNC_END    = V_SYNC_START + V_SYNC_PULSE;   // 492

    reg [9:0] horizontal_count;
    reg [9:0] vertical_count;

    assign pixel_x = horizontal_count;
    assign pixel_y = vertical_count;

    wire last_pixel_in_line = (horizontal_count == H_TOTAL - 1);
    wire last_line_in_frame = (vertical_count   == V_TOTAL - 1);

    // Counters: x counts 0..799, y advances once per line, 0..524
    always @(posedge pixel_clk) begin
        if (!reset_n) begin
            horizontal_count <= 10'd0;
            vertical_count   <= 10'd0;
        end else if (last_pixel_in_line) begin
            horizontal_count <= 10'd0;
            vertical_count   <= last_line_in_frame ? 10'd0 : vertical_count + 10'd1;
        end else begin
            horizontal_count <= horizontal_count + 10'd1;
        end
    end

    // Registered sync outputs (glitch-free at the pins)
    always @(posedge pixel_clk) begin
        if (!reset_n) begin
            hsync_n      <= 1'b1;
            vsync_n      <= 1'b1;
            video_active <= 1'b0;
        end else begin
            hsync_n      <= ~((horizontal_count >= H_SYNC_START) && (horizontal_count < H_SYNC_END));
            vsync_n      <= ~((vertical_count   >= V_SYNC_START) && (vertical_count   < V_SYNC_END));
            video_active <=  (horizontal_count <  H_VISIBLE)     && (vertical_count   < V_VISIBLE);
        end
    end
endmodule
