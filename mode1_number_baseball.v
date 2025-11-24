module mode1_number_baseball(
    input wire clk,
    input wire reset,
    input wire active,
    input wire btn_up,
    input wire btn_down,
    input wire btn_left,
    input wire btn_right,
    input wire btn_confirm,
    output reg [15:0] led,
    output reg [19:0] seg_data
);

    // State definitions
    localparam IDLE = 3'd0;
    localparam INPUT_ANSWER = 3'd1;
    localparam ANSWER_CONFIRM = 3'd2;
    localparam INPUT_GUESS = 3'd3;
    localparam SHOW_RESULT = 3'd4;
    localparam GAME_WIN = 3'd5;
    localparam GAME_LOSE = 3'd6;

    reg [2:0] state, next_state;

    // Answer and guess storage (4 digits, each 4 bits)
    reg [3:0] answer [3:0];
    reg [3:0] guess [3:0];

    // Current digit position (0-3)
    reg [1:0] current_pos;

    // Strike and Ball counters
    reg [3:0] strike_count;
    reg [3:0] ball_count;

    // Attempt counter (max 16)
    reg [4:0] attempt_count;

    // Blink control for current position
    reg blink_clk;
    wire [3:0] display_digit;

    // Button edge detection
    reg btn_up_prev, btn_down_prev, btn_left_prev, btn_right_prev, btn_confirm_prev;
    wire btn_up_edge, btn_down_edge, btn_left_edge, btn_right_edge, btn_confirm_edge;

    assign btn_up_edge = btn_up && !btn_up_prev;
    assign btn_down_edge = btn_down && !btn_down_prev;
    assign btn_left_edge = btn_left && !btn_left_prev;
    assign btn_right_edge = btn_right && !btn_right_prev;
    assign btn_confirm_edge = btn_confirm && !btn_confirm_prev;

    // Clock divider for blinking (500ms period)
    reg [25:0] blink_counter;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            blink_counter <= 0;
            blink_clk <= 0;
        end else begin
            if (blink_counter == 26'd50_000_000) begin  // Adjust for your clock frequency
                blink_counter <= 0;
                blink_clk <= ~blink_clk;
            end else begin
                blink_counter <= blink_counter + 1;
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

    // Button edge detection registers
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            btn_up_prev <= 0;
            btn_down_prev <= 0;
            btn_left_prev <= 0;
            btn_right_prev <= 0;
            btn_confirm_prev <= 0;
        end else begin
            btn_up_prev <= btn_up;
            btn_down_prev <= btn_down;
            btn_left_prev <= btn_left;
            btn_right_prev <= btn_right;
            btn_confirm_prev <= btn_confirm;
        end
    end

    // Next state logic
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (active && !reset)
                    next_state = INPUT_ANSWER;
            end
            INPUT_ANSWER: begin
                if (btn_confirm_edge)
                    next_state = ANSWER_CONFIRM;
            end
            ANSWER_CONFIRM: begin
                if (btn_confirm_edge)
                    next_state = INPUT_GUESS;
            end
            INPUT_GUESS: begin
                if (btn_confirm_edge) begin
                    if (strike_count == 4)
                        next_state = GAME_WIN;
                    else if (attempt_count >= 16)
                        next_state = GAME_LOSE;
                    else
                        next_state = SHOW_RESULT;
                end
            end
            SHOW_RESULT: begin
                if (btn_confirm_edge)
                    next_state = INPUT_GUESS;
            end
            GAME_WIN: begin
                if (reset)
                    next_state = IDLE;
            end
            GAME_LOSE: begin
                if (reset)
                    next_state = IDLE;
            end
        endcase
    end

    // Main logic
    always @(posedge clk or posedge reset) begin
        if (reset || !active) begin
            // Reset all registers
            current_pos <= 0;
            attempt_count <= 0;
            strike_count <= 0;
            ball_count <= 0;
            led <= 16'b0;
            seg_data <= 20'h00000;
            answer[0] <= 0;
            answer[1] <= 0;
            answer[2] <= 0;
            answer[3] <= 0;
            guess[0] <= 0;
            guess[1] <= 0;
            guess[2] <= 0;
            guess[3] <= 0;
        end else begin
            case (state)
                INPUT_ANSWER: begin
                    // Display current input with blinking at current position
                    seg_data[19:15] <= (current_pos == 3 && blink_clk) ? 5'h0F : {1'b0, answer[3]};
                    seg_data[14:10] <= (current_pos == 2 && blink_clk) ? 5'h0F : {1'b0, answer[2]};
                    seg_data[9:5]   <= (current_pos == 1 && blink_clk) ? 5'h0F : {1'b0, answer[1]};
                    seg_data[4:0]   <= (current_pos == 0 && blink_clk) ? 5'h0F : {1'b0, answer[0]};

                    // Handle button presses
                    if (btn_up_edge) begin
                        answer[current_pos] <= (answer[current_pos] == 9) ? 0 : answer[current_pos] + 1;
                    end
                    if (btn_down_edge) begin
                        answer[current_pos] <= (answer[current_pos] == 0) ? 9 : answer[current_pos] - 1;
                    end
                    if (btn_right_edge) begin
                        current_pos <= (current_pos == 3) ? 0 : current_pos + 1;
                    end
                    if (btn_left_edge) begin
                        current_pos <= (current_pos == 0) ? 3 : current_pos - 1;
                    end
                end

                ANSWER_CONFIRM: begin
                    // Check for duplicates - Enhanced error handling
                    if (check_duplicate(answer[0], answer[1], answer[2], answer[3])) begin
                        seg_data <= {5'h0F, 5'h0E, 5'h0E, 5'h0E};  // Display "-Err" (F=blank, E=E, E=r, E=r)
                        // Stay in this state until valid input - prevent advancement
                        if (btn_confirm_edge) begin
                            next_state <= INPUT_ANSWER;  // Go back to input
                        end
                    end else begin
                        seg_data <= {5'h09, 5'h00, 5'h09, 5'h00};  // Display "gogo"
                    end
                end

                INPUT_GUESS: begin
                    // Display current input with blinking at current position
                    seg_data[19:15] <= (current_pos == 3 && blink_clk) ? 5'h0F : {1'b0, guess[3]};
                    seg_data[14:10] <= (current_pos == 2 && blink_clk) ? 5'h0F : {1'b0, guess[2]};
                    seg_data[9:5]   <= (current_pos == 1 && blink_clk) ? 5'h0F : {1'b0, guess[1]};
                    seg_data[4:0]   <= (current_pos == 0 && blink_clk) ? 5'h0F : {1'b0, guess[0]};

                    // Handle button presses for guess input
                    if (btn_up_edge) begin
                        guess[current_pos] <= (guess[current_pos] == 9) ? 0 : guess[current_pos] + 1;
                    end
                    if (btn_down_edge) begin
                        guess[current_pos] <= (guess[current_pos] == 0) ? 9 : guess[current_pos] - 1;
                    end
                    if (btn_right_edge) begin
                        current_pos <= (current_pos == 3) ? 0 : current_pos + 1;
                    end
                    if (btn_left_edge) begin
                        current_pos <= (current_pos == 0) ? 3 : current_pos - 1;
                    end

                    // Confirm guess and check for duplicates
                    if (btn_confirm_edge) begin
                        // Enhanced: Check for duplicate digits in guess too
                        if (!check_duplicate(guess[0], guess[1], guess[2], guess[3])) begin
                            attempt_count <= attempt_count + 1;
                            led[attempt_count] <= 1'b1;
                            // Calculate strike and ball
                            calculate_strike_ball();
                        end else begin
                            // Show error but don't count as attempt
                            seg_data <= {5'h0F, 5'h0E, 5'h0E, 5'h0E};  // Display "-Err"
                        end
                    end
                end

                SHOW_RESULT: begin
                    // Display strike and ball count
                    seg_data[19:15] <= {1'b0, strike_count};
                    seg_data[14:10] <= 5'h0B;  // 'S'
                    seg_data[9:5]   <= {1'b0, ball_count};
                    seg_data[4:0]   <= 5'h0A;  // 'B'
                end

                GAME_WIN: begin
                    seg_data <= {5'h09, 5'h00, 5'h00, 5'h0D};  // Display "good"
                end

                GAME_LOSE: begin
                    seg_data <= {5'h0C, 5'h00, 5'h05, 5'h0E};  // Display "LOSE"
                end
            endcase
        end
    end

    // Function to check duplicate digits
    function check_duplicate;
        input [3:0] d0, d1, d2, d3;
        begin
            check_duplicate = (d0 == d1) || (d0 == d2) || (d0 == d3) ||
                             (d1 == d2) || (d1 == d3) || (d2 == d3);
        end
    endfunction

    // Task to calculate strike and ball
    task calculate_strike_ball;
        integer i, j;
        begin
            strike_count = 0;
            ball_count = 0;

            // Count strikes
            for (i = 0; i < 4; i = i + 1) begin
                if (guess[i] == answer[i])
                    strike_count = strike_count + 1;
            end

            // Count balls
            for (i = 0; i < 4; i = i + 1) begin
                for (j = 0; j < 4; j = j + 1) begin
                    if (i != j && guess[i] == answer[j])
                        ball_count = ball_count + 1;
                end
            end
        end
    endtask

endmodule
