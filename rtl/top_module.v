module top_module(
    input wire clk,
    input wire reset,
    input wire [2:0] mode_sw,
    input wire btn_up,
    input wire btn_down,
    input wire btn_left,
    input wire btn_right,
    input wire btn_center,
    output wire [15:0] led,
    output wire [6:0] seg,
    output wire dp,
    output wire [3:0] an
);

    // Debounced button signals
    wire btn_up_db, btn_down_db, btn_left_db, btn_right_db, btn_center_db;

    // Button debouncers
    button_debouncer #(.DEBOUNCE_TIME(20)) debounce_up (
        .clk(clk), .reset(reset), .btn_in(btn_up), .btn_out(btn_up_db)
    );

    button_debouncer #(.DEBOUNCE_TIME(20)) debounce_down (
        .clk(clk), .reset(reset), .btn_in(btn_down), .btn_out(btn_down_db)
    );

    button_debouncer #(.DEBOUNCE_TIME(20)) debounce_left (
        .clk(clk), .reset(reset), .btn_in(btn_left), .btn_out(btn_left_db)
    );

    button_debouncer #(.DEBOUNCE_TIME(20)) debounce_right (
        .clk(clk), .reset(reset), .btn_in(btn_right), .btn_out(btn_right_db)
    );

    button_debouncer #(.DEBOUNCE_TIME(20)) debounce_center (
        .clk(clk), .reset(reset), .btn_in(btn_center), .btn_out(btn_center_db)
    );

    // Internal signals
    wire [15:0] led_mode1, led_mode2, led_mode3;
    wire [19:0] seg_data_mode1, seg_data_mode2, seg_data_mode3;
    wire [3:0] dp_data_mode1, dp_data_mode2, dp_data_mode3;
    wire [19:0] seg_data;
    wire [3:0] dp_data;

    // Mode detection
    wire mode1_active = (mode_sw == 3'b001);  // Mode1: Number Baseball
    wire mode2_active = (mode_sw == 3'b011);  // Mode2: LED Count
    wire mode3_active = (mode_sw == 3'b111);  // Mode3: Credits

    // Mode 1: Number Baseball Game
    mode1_number_baseball mode1(
        .clk(clk),
        .reset(reset),
        .active(mode1_active),
        .btn_up(btn_up_db),
        .btn_down(btn_down_db),
        .btn_left(btn_left_db),
        .btn_right(btn_right_db),
        .btn_confirm(btn_center_db), 
        .led(led_mode1),
        .seg_data(seg_data_mode1),
        .dp_data(dp_data_mode1)
    );

    // Mode 2: LED Count Game
    mode2_led_count mode2(
        .clk(clk),
        .reset(reset),
        .active(mode2_active),
        .btn_go_stop(btn_center_db),
        .led(led_mode2),
        .seg_data(seg_data_mode2),
        .dp_data(dp_data_mode2)
    );

    // Mode 3: Credits Display
    mode3_credits mode3(
        .clk(clk),
        .reset(reset),
        .active(mode3_active),
        .led(led_mode3),
        .seg_data(seg_data_mode3),
        .dp_data(dp_data_mode3)
    );

    // Mode multiplexing
    assign led = mode1_active ? led_mode1 :
                 mode2_active ? led_mode2 :
                 mode3_active ? led_mode3 : 16'b0;

    assign seg_data = mode1_active ? seg_data_mode1 :
                      mode2_active ? seg_data_mode2 :
                      mode3_active ? seg_data_mode3 : 20'b0;

    assign dp_data = mode1_active ? dp_data_mode1 :
                     mode2_active ? dp_data_mode2 :
                     mode3_active ? dp_data_mode3 : 4'b0;

    // 7-segment display controller
    seg_display_controller seg_ctrl(
        .clk(clk),
        .reset(reset),
        .seg_data(seg_data),
        .dp_data(dp_data),
        .seg(seg),
        .dp(dp),
        .an(an)
    );

endmodule
