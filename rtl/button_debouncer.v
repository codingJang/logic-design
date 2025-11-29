module button_debouncer #(
    parameter DEBOUNCE_TIME = 20  // Debounce time in ms
)(
    input wire clk,
    input wire reset,
    input wire btn_in,
    output reg btn_out
);

    // 100MHz clock: 20ms = 2,000,000 cycles
    localparam COUNTER_MAX = DEBOUNCE_TIME * 100_000;

    reg [20:0] counter;
    reg btn_sync_0, btn_sync_1;  // Synchronizer flip-flops
    reg btn_state;

    // Two-stage synchronizer to prevent metastability
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            btn_sync_0 <= 1'b0;
            btn_sync_1 <= 1'b0;
        end else begin
            btn_sync_0 <= btn_in;
            btn_sync_1 <= btn_sync_0;
        end
    end

    // Debounce logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            btn_state <= 1'b0;
            btn_out <= 1'b0;
        end else begin
            if (btn_sync_1 != btn_state) begin
                if (counter < COUNTER_MAX) begin
                    counter <= counter + 1;
                end else begin
                    btn_state <= btn_sync_1;
                    btn_out <= btn_sync_1;
                    counter <= 0;
                end
            end else begin
                counter <= 0;
            end
        end
    end

endmodule
