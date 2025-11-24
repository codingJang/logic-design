module mode2_led_count(
    input wire clk,
    input wire reset,
    input wire active,
    input wire btn_go_stop,
    output reg [15:0] led,
    output reg [15:0] seg_data
);

    // State definitions
    localparam IDLE = 2'd0;
    localparam RUNNING = 2'd1;
    localparam STOPPED = 2'd2;
    localparam WIN = 2'd3;

    reg [1:0] state, next_state;

    // Random target number (1-16)
    reg [4:0] target_count;

    // Current LED count (0-16)
    reg [4:0] current_count;

    // LED wave animation control
    reg [4:0] wave_position;  // 0-15 for LED position
    reg wave_direction;       // 0: left to right, 1: right to left

    // Clock divider for 1 second period
    reg [26:0] clk_counter;
    wire clk_1s;
    assign clk_1s = (clk_counter == 27'd100_000_000);  // Adjust for your clock frequency

    // Button edge detection
    reg btn_go_stop_prev;
    wire btn_go_stop_edge;
    assign btn_go_stop_edge = btn_go_stop && !btn_go_stop_prev;

    // Clock divider for 1Hz (1 second period)
    always @(posedge clk or posedge reset) begin
        if (reset || !active) begin
            clk_counter <= 0;
        end else begin
            if (clk_counter == 27'd100_000_000) begin  // Adjust based on your FPGA clock
                clk_counter <= 0;
            end else begin
                clk_counter <= clk_counter + 1;
            end
        end
    end

    // State register
    always @(posedge clk or posedge reset) begin
        if (reset || !active) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // Button edge detection
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            btn_go_stop_prev <= 0;
        end else begin
            btn_go_stop_prev <= btn_go_stop;
        end
    end

    // Next state logic
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (active && !reset)
                    next_state = RUNNING;
            end
            RUNNING: begin
                if (btn_go_stop_edge)
                    next_state = STOPPED;
            end
            STOPPED: begin
                if (current_count == target_count)
                    next_state = WIN;
                else if (btn_go_stop_edge)
                    next_state = RUNNING;
            end
            WIN: begin
                if (reset)
                    next_state = IDLE;
            end
        endcase
    end

    // LFSR for pseudo-random number generation (1-16)
    reg [15:0] lfsr;
    wire feedback = lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10];

    always @(posedge clk or posedge reset) begin
        if (reset || !active) begin
            lfsr <= 16'hACE1;  // Seed value
        end else begin
            lfsr <= {lfsr[14:0], feedback};
        end
    end

    // Main logic
    always @(posedge clk or posedge reset) begin
        if (reset || !active) begin
            target_count <= 5'd1;
            current_count <= 5'd0;
            wave_position <= 5'd15;
            wave_direction <= 0;
            led <= 16'b0;
            seg_data <= 16'h0000;
        end else begin
            case (state)
                IDLE: begin
                    // Generate random target (1-16)
                    target_count <= (lfsr[3:0] == 0) ? 5'd16 : {1'b0, lfsr[3:0]};
                    if (target_count < 10) begin
                        seg_data[15:8] <= 8'hFF;  // Blank left 2 digits
                        seg_data[7:4] <= 4'h0;
                        seg_data[3:0] <= target_count[3:0];
                    end else begin
                        seg_data[15:8] <= 8'hFF;  // Blank left 2 digits
                        seg_data[7:4] <= 4'h1;
                        seg_data[3:0] <= target_count[3:0] - 4'd10;
                    end
                    current_count <= 0;
                    wave_position <= 15;
                    led <= 16'b0;
                end

                RUNNING: begin
                    // LED wave animation (1 second period)
                    if (clk_1s) begin
                        // Update wave position
                        if (wave_direction == 0) begin
                            // Moving left to right (15 -> 0)
                            if (wave_position == 0) begin
                                wave_direction <= 1;
                                wave_position <= 1;
                            end else begin
                                wave_position <= wave_position - 1;
                            end
                        end else begin
                            // Moving right to left (0 -> 15)
                            if (wave_position == 15) begin
                                wave_direction <= 0;
                                wave_position <= 14;
                            end else begin
                                wave_position <= wave_position + 1;
                            end
                        end

                        // Update current count and LED display
                        current_count <= current_count + 1;
                        if (current_count >= 16)
                            current_count <= 1;
                    end

                    // Show wave pattern: all LEDs from 15 down to wave_position are ON
                    integer i;
                    for (i = 0; i < 16; i = i + 1) begin
                        if (i >= wave_position)
                            led[i] <= 1'b1;
                        else
                            led[i] <= 1'b0;
                    end

                    // Display target count on right 2 segments
                    if (target_count < 10) begin
                        seg_data[15:8] <= 8'hFF;
                        seg_data[7:4] <= 4'h0;
                        seg_data[3:0] <= target_count[3:0];
                    end else begin
                        seg_data[15:8] <= 8'hFF;
                        seg_data[7:4] <= 4'h1;
                        seg_data[3:0] <= target_count[3:0] - 4'd10;
                    end
                end

                STOPPED: begin
                    // Freeze LED state
                    // Count how many LEDs are on
                    current_count = 0;
                    for (integer j = 0; j < 16; j = j + 1) begin
                        if (led[j])
                            current_count = current_count + 1;
                    end

                    // Display current count on left 2 segments
                    if (current_count < 10) begin
                        seg_data[15:12] <= 4'h0;
                        seg_data[11:8] <= current_count[3:0];
                    end else begin
                        seg_data[15:12] <= 4'h1;
                        seg_data[11:8] <= current_count[3:0] - 4'd10;
                    end

                    // Display UP or dn on right 2 segments
                    if (current_count < target_count) begin
                        seg_data[7:4] <= 4'hD;   // 'U'
                        seg_data[3:0] <= 4'hE;   // 'P'
                    end else if (current_count > target_count) begin
                        seg_data[7:4] <= 4'hC;   // 'd'
                        seg_data[3:0] <= 4'hA;   // 'n'
                    end
                end

                WIN: begin
                    // Display winning pattern
                    seg_data[15:12] <= 4'h9;  // 'g'
                    seg_data[11:8] <= 4'h0;   // 'o'
                    seg_data[7:4] <= 4'h0;    // 'o'
                    seg_data[3:0] <= 4'hD;    // 'd'
                end
            endcase
        end
    end

endmodule
