module top_module(
    input wire clk,              // System clock
    input wire reset,            // Reset switch (active high when up)
    input wire [2:0] mode_sw,    // Mode selection switches [2:0]
    input wire btn_up,           // Up button
    input wire btn_down,         // Down button
    input wire btn_left,         // Left button
    input wire btn_right,        // Right button
    input wire btn_confirm,      // Confirm button (center)
    input wire btn_go_stop,      // GO/STOP button for Mode2
    output wire [15:0] led,      // 16 LEDs
    output wire [6:0] seg,       // 7-segment display segments
    output wire [3:0] an         // 7-segment display anodes (4 digits)
);

    // Internal signals
    wire [15:0] led_mode1, led_mode2, led_mode3;
    wire [15:0] seg_data_mode1, seg_data_mode2, seg_data_mode3;
    wire [15:0] seg_data;

    // Mode detection
    wire mode1_active = (mode_sw == 3'b001);  // One switch up: Mode1 (Number Baseball)
    wire mode2_active = (mode_sw == 3'b011);  // Two switches up: Mode2 (LED Count)
    wire mode3_active = (mode_sw == 3'b111);  // Three switches up: Mode3 (Credits)

    // Instantiate Mode 1: Number Baseball Game
    mode1_number_baseball mode1(
        .clk(clk),
        .reset(reset),
        .active(mode1_active),
        .btn_up(btn_up),
        .btn_down(btn_down),
        .btn_left(btn_left),
        .btn_right(btn_right),
        .btn_confirm(btn_confirm),
        .led(led_mode1),
        .seg_data(seg_data_mode1)
    );

    // Instantiate Mode 2: LED Count Game
    mode2_led_count mode2(
        .clk(clk),
        .reset(reset),
        .active(mode2_active),
        .btn_go_stop(btn_go_stop),
        .led(led_mode2),
        .seg_data(seg_data_mode2)
    );

    // Instantiate Mode 3: Credits Display
    mode3_credits mode3(
        .clk(clk),
        .reset(reset),
        .active(mode3_active),
        .led(led_mode3),
        .seg_data(seg_data_mode3)
    );

    // Mode multiplexing for outputs
    assign led = mode1_active ? led_mode1 :
                 mode2_active ? led_mode2 :
                 mode3_active ? led_mode3 : 16'b0;

    assign seg_data = mode1_active ? seg_data_mode1 :
                      mode2_active ? seg_data_mode2 :
                      mode3_active ? seg_data_mode3 : 16'h0000;

    // 7-segment display controller
    seg_display_controller seg_ctrl(
        .clk(clk),
        .reset(reset),
        .seg_data(seg_data),
        .seg(seg),
        .an(an)
    );

endmodule
