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
    reg [25:0] blink_counter;

    // Button edge detection
    reg btn_up_prev, btn_down_prev, btn_left_prev, btn_right_prev, btn_confirm_prev;
    wire btn_up_edge, btn_down_edge, btn_left_edge, btn_right_edge, btn_confirm_edge;

    assign btn_up_edge = btn_up && !btn_up_prev;
    assign btn_down_edge = btn_down && !btn_down_prev;
    assign btn_left_edge = btn_left && !btn_left_prev;
    assign btn_right_edge = btn_right && !btn_right_prev;
    assign btn_confirm_edge = btn_confirm && !btn_confirm_prev;

    // 20비트 문자 매핑 상수를 정의 (seg_display_controller와 일치)
    localparam C_BLANK  = 5'd31; // 꺼짐 (깜빡임용)
    localparam C_HYPHEN = 5'd10; // -
    localparam C_E      = 5'd11; // E
    localparam C_r      = 5'd12; // r
    localparam C_g      = 5'd9;  // g (숫자 9 모양)
    localparam C_o      = 5'd17; // o (네모 모양)
    localparam C_S      = 5'd5;  // S (숫자 5 모양)
    localparam C_b      = 5'd18; // b
    localparam C_d      = 5'd19; // d
    localparam C_1      = 5'd1;  // 1 (L 대용)

    // 중복 체크 함수
    function check_duplicate;
        input [3:0] d0, d1, d2, d3;
        begin
            check_duplicate = (d0 == d1) || (d0 == d2) || (d0 == d3) ||
                             (d1 == d2) || (d1 == d3) || (d2 == d3);
        end
    endfunction

    // Blink Timer
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            blink_counter <= 0;
            blink_clk <= 0;
        end else begin
            if (blink_counter == 26'd50_000_000) begin
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

    // State Register
    always @(posedge clk or posedge reset) begin
        if (reset || !active) state <= IDLE;
        else state <= next_state;
    end

    // Button Edge Registers
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            btn_up_prev <= 0; btn_down_prev <= 0; btn_left_prev <= 0;
            btn_right_prev <= 0; btn_confirm_prev <= 0;
        end else begin
            btn_up_prev <= btn_up; btn_down_prev <= btn_down; btn_left_prev <= btn_left;
            btn_right_prev <= btn_right; btn_confirm_prev <= btn_confirm;
        end
    end

    // Next State Logic (중복 검사 로직을 이곳으로 통합하여 버그 수정)
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (active && !reset) next_state = INPUT_ANSWER;
            end
            INPUT_ANSWER: begin
                if (btn_confirm_edge) next_state = ANSWER_CONFIRM;
            end
            ANSWER_CONFIRM: begin
                if (btn_confirm_edge) begin
                    // 중복이면 다시 입력으로, 아니면 게임 시작
                    if (check_duplicate(answer[0], answer[1], answer[2], answer[3]))
                        next_state = INPUT_ANSWER;
                    else
                        next_state = INPUT_GUESS;
                end
            end
            INPUT_GUESS: begin
                if (btn_confirm_edge) begin
                    // 추측값 중복이면 상태 유지 (에러만 표시)
                    if (check_duplicate(guess[0], guess[1], guess[2], guess[3])) begin
                        next_state = INPUT_GUESS;
                    end else begin
                        // 중복 없으면 결과 판정
                        if (guess[0]==answer[0] && guess[1]==answer[1] && 
                            guess[2]==answer[2] && guess[3]==answer[3])
                            next_state = GAME_WIN;
                        else if (attempt_count >= 15) // 이번이 16번째
                            next_state = GAME_LOSE;
                        else
                            next_state = SHOW_RESULT;
                    end
                end
            end
            SHOW_RESULT: begin
                if (btn_confirm_edge) next_state = INPUT_GUESS;
            end
            GAME_WIN: begin
                if (reset) next_state = IDLE;
            end
            GAME_LOSE: begin
                if (reset) next_state = IDLE;
            end
        endcase
    end

    // Main Logic & Output
    always @(posedge clk or posedge reset) begin
        if (reset || !active) begin
            current_pos <= 0; attempt_count <= 0;
            strike_count <= 0; ball_count <= 0;
            led <= 16'b0; 
            seg_data <= {5'd0, 5'd0, 5'd0, 5'd0}; // 0000
            answer[0] <= 0; answer[1] <= 0; answer[2] <= 0; answer[3] <= 0;
            guess[0] <= 0; guess[1] <= 0; guess[2] <= 0; guess[3] <= 0;
        end else begin
            case (state)
                INPUT_ANSWER: begin
                    // 깜빡임에 C_BLANK(31) 사용, 숫자는 앞에 0붙여 5비트로
                    seg_data[19:15] <= (current_pos == 3 && blink_clk) ? C_BLANK : {1'b0, answer[3]};
                    seg_data[14:10] <= (current_pos == 2 && blink_clk) ? C_BLANK : {1'b0, answer[2]};
                    seg_data[9:5]   <= (current_pos == 1 && blink_clk) ? C_BLANK : {1'b0, answer[1]};
                    seg_data[4:0]   <= (current_pos == 0 && blink_clk) ? C_BLANK : {1'b0, answer[0]};

                    if (btn_up_edge) answer[current_pos] <= (answer[current_pos] == 9) ? 0 : answer[current_pos] + 1;
                    if (btn_down_edge) answer[current_pos] <= (answer[current_pos] == 0) ? 9 : answer[current_pos] - 1;
                    if (btn_right_edge) current_pos <= (current_pos == 3) ? 0 : current_pos + 1;
                    if (btn_left_edge) current_pos <= (current_pos == 0) ? 3 : current_pos - 1;
                end

                ANSWER_CONFIRM: begin
                    // [수정됨] -Err / gogo 표시
                    if (check_duplicate(answer[0], answer[1], answer[2], answer[3])) begin
                        seg_data <= {C_HYPHEN, C_E, C_r, C_r}; // -Err
                    end else begin
                        seg_data <= {C_g, C_o, C_g, C_o};      // gogo
                    end
                end

                INPUT_GUESS: begin
                    // 깜빡임에 C_BLANK 사용
                    seg_data[19:15] <= (current_pos == 3 && blink_clk) ? C_BLANK : {1'b0, guess[3]};
                    seg_data[14:10] <= (current_pos == 2 && blink_clk) ? C_BLANK : {1'b0, guess[2]};
                    seg_data[9:5]   <= (current_pos == 1 && blink_clk) ? C_BLANK : {1'b0, guess[1]};
                    seg_data[4:0]   <= (current_pos == 0 && blink_clk) ? C_BLANK : {1'b0, guess[0]};

                    if (btn_up_edge) guess[current_pos] <= (guess[current_pos] == 9) ? 0 : guess[current_pos] + 1;
                    if (btn_down_edge) guess[current_pos] <= (guess[current_pos] == 0) ? 9 : guess[current_pos] - 1;
                    if (btn_right_edge) current_pos <= (current_pos == 3) ? 0 : current_pos + 1;
                    if (btn_left_edge) current_pos <= (current_pos == 0) ? 3 : current_pos - 1;

                    if (btn_confirm_edge) begin
                        if (!check_duplicate(guess[0], guess[1], guess[2], guess[3])) begin
                            attempt_count <= attempt_count + 1;
                            led[attempt_count] <= 1'b1;
                            calculate_strike_ball();
                        end else begin
                            seg_data <= {C_HYPHEN, C_E, C_r, C_r}; // -Err
                        end
                    end
                end

                SHOW_RESULT: begin
                    // 1S 1b 표시 (S=5, b=18)
                    seg_data[19:15] <= {1'b0, strike_count};
                    seg_data[14:10] <= C_S;
                    seg_data[9:5]   <= {1'b0, ball_count};
                    seg_data[4:0]   <= C_b; 
                end

                GAME_WIN: begin
                    seg_data <= {C_g, C_o, C_o, C_d}; // good
                end

                GAME_LOSE: begin
                    seg_data <= {C_1, C_o, C_S, C_E}; // 1OSE (L대신 1사용)
                end
            endcase
        end
    end

    // Task for S/B calculation
    task calculate_strike_ball;
        integer i, j;
        begin
            strike_count = 0;
            ball_count = 0;
            for (i = 0; i < 4; i = i + 1) begin
                if (guess[i] == answer[i]) strike_count = strike_count + 1;
            end
            for (i = 0; i < 4; i = i + 1) begin
                for (j = 0; j < 4; j = j + 1) begin
                    if (i != j && guess[i] == answer[j]) ball_count = ball_count + 1;
                end
            end
        end
    endtask

endmodule