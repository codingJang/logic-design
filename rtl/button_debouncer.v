module button_debouncer #(
    parameter DEBOUNCE_TIME = 20  // 20ms debounce time (2,000,000 clock cycles at 100MHz)
)(
    input wire clk,
    input wire reset,
    input wire btn_in,
    output reg btn_out
);

    // Counter for debounce timing (100MHz clock = 10ns period)
    // 20ms = 20,000,000ns = 2,000,000 clock cycles
    localparam COUNTER_MAX = DEBOUNCE_TIME * 100_000;  // 20ms * 100,000 cycles/ms

    reg [20:0] counter;  // 21 bits to count up to 2,000,000
    reg btn_sync_0, btn_sync_1;  // Synchronizer flip-flops
    reg btn_state;  // Current stable button state

    // Synchronizer to avoid metastability
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
                // Button state is changing, start/continue counting
                if (counter < COUNTER_MAX) begin
                    counter <= counter + 1;
                end else begin
                    // Debounce time has elapsed, update stable state
                    btn_state <= btn_sync_1;
                    btn_out <= btn_sync_1;
                    counter <= 0;
                end
            end else begin
                // Button state is stable, reset counter
                counter <= 0;
            end
        end
    end

endmodule


// ==============================================================
// Button Debouncer Module
// ==============================================================
//
// Purpose:
// Mechanical buttons can produce multiple transitions (bouncing)
// when pressed or released. This module filters out these rapid
// transitions to provide a clean, stable output signal.
//
// How it works:
// 1. Synchronizes the input button signal to avoid metastability
// 2. Requires the button to remain stable for DEBOUNCE_TIME before
//    registering a state change
// 3. Outputs a clean signal that changes only after the button
//    has been stable for the full debounce period
//
// Parameters:
// - DEBOUNCE_TIME: Time in milliseconds (default 20ms)
//
// Usage:
// Instantiate one debouncer for each button:
//
//   button_debouncer #(.DEBOUNCE_TIME(20)) debounce_up (
//       .clk(clk),
//       .reset(reset),
//       .btn_in(btn_up_raw),
//       .btn_out(btn_up_clean)
//   );
//
// Timing:
// At 100MHz clock:
// - 20ms debounce = 2,000,000 clock cycles
// - Typical mechanical button bounce: 5-20ms
//
// Resources:
// - Per button: 1 counter (21 bits) + 4 flip-flops
// - Very minimal resource usage
//
// ==============================================================
