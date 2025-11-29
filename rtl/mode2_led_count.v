module mode2_led_count(
    input wire clk,
    input wire reset,
    input wire active,
    input wire btn_go_stop,
    output reg [15:0] led,
    output reg [19:0] seg_data,
    output wire [3:0] dp_data
);

    assign dp_data = 4'b0000;

    // State definitions
    localparam IDLE = 2'd0;
    localparam RUNNING = 2'd1;
    localparam STOPPED = 2'd2;
    localparam WIN = 2'd3;

    reg [1:0] state, next_state;

    // Game variables
    reg [4:0] target_count;    // Random target (1-16)
    reg [4:0] current_count;   // LED count (0-16)
    reg [4:0] wave_position;   // 0-15
    reg wave_direction;        // 0: L->R, 1: R->L

    // Character codes
    localparam C_BLANK  = 5'd31;
    localparam C_HYPHEN = 5'd10;
    localparam C_U      = 5'd15;
    localparam C_P      = 5'd16;
    localparam C_d      = 5'd19;
    localparam C_n      = 5'd20;
    localparam C_g      = 5'd9;
    localparam C_o      = 5'd17;

    // 1 second timer
    reg [26:0] clk_counter;
    wire clk_1s;
    assign clk_1s = (clk_counter == 27'd100_000_000);

    // Button edge detection
    reg btn_go_stop_prev;
    wire btn_confirm_edge;
    assign btn_confirm_edge = btn_go_stop && !btn_go_stop_prev;

    // Timer logic
    always @(posedge clk or posedge reset) begin
        if (reset || !active) clk_counter <= 0;
        else begin
            if (clk_counter == 27'd100_000_000) clk_counter <= 0;
            else clk_counter <= clk_counter + 1;
        end
    end

    // State register
    always @(posedge clk or posedge reset) begin
        if (reset || !active) state <= IDLE;
        else state <= next_state;
    end

    // Button register
    always @(posedge clk or posedge reset) begin
        if (reset) btn_go_stop_prev <= 0;
        else btn_go_stop_prev <= btn_go_stop;
    end

    // Next state logic
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (active && !reset) next_state = RUNNING;
            end
            RUNNING: begin
                if (btn_confirm_edge) next_state = STOPPED;
            end
            STOPPED: begin
                if (led_count_reg == target_count) next_state = WIN;
                else if (btn_confirm_edge) next_state = RUNNING;
            end
            WIN: begin
                if (reset) next_state = IDLE;
            end
        endcase
    end

    // LFSR random number generator
    reg [15:0] lfsr;
    wire feedback = lfsr[15] ^ lfsr[14] ^ lfsr[12] ^ lfsr[3];
    reg [15:0] seed_counter;
    wire [15:0] new_seed;
    assign new_seed = {seed_counter[7:0], seed_counter[15:8]} ^ 16'hACE1;

    // Seed counter always increments
    always @(posedge clk) begin
        seed_counter <= seed_counter + 1;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            lfsr <= (new_seed == 16'h0000) ? 16'h0001 : new_seed;
        end else if (!active) begin
            lfsr <= (new_seed == 16'h0000) ? 16'h0001 : new_seed;
        end else begin
            lfsr <= {lfsr[14:0], feedback};
        end
    end

    integer i;

    // LED count register
    reg [4:0] led_count_reg;

    // Main logic and display
    always @(posedge clk or posedge reset) begin
        if (reset || !active) begin
            target_count <= (lfsr[3:0] == 0) ? 5'd16 : {1'b0, lfsr[3:0]};
            current_count <= 5'd0;
            led_count_reg <= 5'd0;
            wave_position <= 5'd15;
            wave_direction <= 0;
            led <= 16'b0;
            seg_data <= {C_HYPHEN, C_HYPHEN, C_HYPHEN, C_HYPHEN};
        end else begin
            case (state)
                IDLE: begin
                    target_count <= (lfsr[3:0] == 0) ? 5'd16 : {1'b0, lfsr[3:0]};
                    
                    if (target_count < 10)
                        seg_data <= {5'd0, {1'b0, target_count[3:0]}, C_HYPHEN, C_HYPHEN};
                    else
                        seg_data <= {5'd1, {1'b0, target_count[3:0] - 4'd10}, C_HYPHEN, C_HYPHEN};
                    
                    current_count <= 0;
                    wave_position <= 15;
                    led <= 16'b0;
                end

                RUNNING: begin
                    if (clk_1s) begin
                        if (wave_direction == 0) begin // L -> R
                            if (wave_position == 0) begin
                                wave_direction <= 1;
                                wave_position <= 1;
                            end else wave_position <= wave_position - 1;
                        end else begin // R -> L
                            if (wave_position == 15) begin
                                wave_direction <= 0;
                                wave_position <= 14;
                            end else wave_position <= wave_position + 1;
                        end

                        current_count <= current_count + 1;
                        if (current_count >= 16) current_count <= 1;
                    end

                    for (i = 0; i < 16; i = i + 1) begin
                        led[i] <= (i >= wave_position) ? 1'b1 : 1'b0;
                    end

                    if (target_count < 10)
                        seg_data <= {5'd0, {1'b0, target_count[3:0]}, C_HYPHEN, C_HYPHEN};
                    else
                        seg_data <= {5'd1, {1'b0, target_count[3:0] - 4'd10}, C_HYPHEN, C_HYPHEN};
                end

                STOPPED: begin
                    led_count_reg <= led[0] + led[1] + led[2] + led[3] + 
                                    led[4] + led[5] + led[6] + led[7] +
                                    led[8] + led[9] + led[10] + led[11] +
                                    led[12] + led[13] + led[14] + led[15];
                    
                    if (led_count_reg < 10) begin
                        if (led_count_reg < target_count)
                            seg_data <= {5'd0, {1'b0, led_count_reg[3:0]}, C_U, C_P};
                        else
                            seg_data <= {5'd0, {1'b0, led_count_reg[3:0]}, C_d, C_n};
                    end else begin
                        if (led_count_reg < target_count)
                            seg_data <= {5'd1, {1'b0, led_count_reg[3:0] - 4'd10}, C_U, C_P};
                        else
                            seg_data <= {5'd1, {1'b0, led_count_reg[3:0] - 4'd10}, C_d, C_n};
                    end
                end

                WIN: begin
                    seg_data <= {C_g, C_o, C_o, C_d};
                end
            endcase
        end
    end

endmodule
