module seg_display_controller(
    input wire clk,
    input wire reset,
    input wire [19:0] seg_data,  // 4 digits to display (5 bits each = 32 characters)
    output reg [6:0] seg,         // 7-segment cathodes (a-g)
    output reg [3:0] an           // 4 anodes for 4 digits
);

    // Refresh counter for multiplexing (approximately 1kHz refresh per digit)
    reg [16:0] refresh_counter;
    wire [1:0] digit_select;
    assign digit_select = refresh_counter[16:15];  // Select which digit to display

    // Current digit data to decode
    reg [4:0] current_digit;  // 5 bits = 32 possible characters

    // Refresh counter
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            refresh_counter <= 0;
        end else begin
            refresh_counter <= refresh_counter + 1;
        end
    end

    // Anode control (active low) - select which digit is active
    always @(*) begin
        case (digit_select)
            2'b00: an = 4'b0111;  // Activate digit 3 (leftmost)
            2'b01: an = 4'b1011;  // Activate digit 2
            2'b10: an = 4'b1101;  // Activate digit 1
            2'b11: an = 4'b1110;  // Activate digit 0 (rightmost)
            default: an = 4'b1111;
        endcase
    end

    // Select current digit data from seg_data
    always @(*) begin
        case (digit_select)
            2'b00: current_digit = seg_data[19:15];  // Digit 3 (leftmost)
            2'b01: current_digit = seg_data[14:10];  // Digit 2
            2'b10: current_digit = seg_data[9:5];    // Digit 1
            2'b11: current_digit = seg_data[4:0];    // Digit 0 (rightmost)
            default: current_digit = 5'd31;
        endcase
    end

    // Enhanced 7-segment decoder (cathode control - active low for common anode display)
    // Segment mapping: {g, f, e, d, c, b, a}
    // 5-bit encoding allows 32 custom characters (5'h00 to 5'h1F)
    always @(*) begin
        case (current_digit)
            // [0~9] 숫자 (기본 정의)
            5'd0: seg = 7'b1000000;
            5'd1: seg = 7'b1111001;
            5'd2: seg = 7'b0100100;
            5'd3: seg = 7'b0110000;
            5'd4: seg = 7'b0011001;
            5'd5: seg = 7'b0010010; // 'S' 모양 겸용
            5'd6: seg = 7'b0000010;
            5'd7: seg = 7'b1111000;
            5'd8: seg = 7'b0000000;
            5'd9: seg = 7'b0010000; // 'g' 모양 겸용
                        // 10: - (Hyphen) : 1000000
            5'd10: seg = 7'b0111111; 
            
            // 11: E : 1111001
            5'd11: seg = 7'b0000110;

            // 12: r : 1010000
            5'd12: seg = 7'b0101111;

            // 13: L : 0111000
            5'd13: seg = 7'b1000111;

            // 14: H : 0001001 (이미지 수치 그대로 적용)
            // (참고: 이미지 수치대로면 b,c,e,f,g 켜짐 -> H 모양 맞음)
            5'd14: seg = 7'b1110110; 

            // 15: U : 0111110
            5'd15: seg = 7'b1000001;

            // 16: P : 1110011
            5'd16: seg = 7'b0001100;

            // 17: o (square) : 1011100
            5'd17: seg = 7'b0100011;

            // 18: b : 1111100
            5'd18: seg = 7'b0000011;

            // 19: d : 1011110
            5'd19: seg = 7'b0100001;

            // 20: n (pi) : 1010100
            5'd20: seg = 7'b0101011;

            // 21: J (reversed L) : 0001110
            5'd21: seg = 7'b1110001;

            // 22: y : 1101110
            5'd22: seg = 7'b0010001;

            // [기타]
            5'd30: seg = 7'b0001011; // 소문자 h (이미지엔 H만 있어서 혹시 몰라 추가, 6변형)
            5'd31: seg = 7'b1111111; // Blank (완전 꺼짐)

            default: seg = 7'b1111111;
        endcase
    end
endmodule


// ==============================================================
// SEGMENT ENCODING REFERENCE:
// ==============================================================
//
// 7-segment display layout:
//      a
//     ---
//  f |   | b
//     -g-
//  e |   | c
//     ---
//      d
//
// Segment encoding (active low for common anode):
// seg[6:0] = {g, f, e, d, c, b, a}
//
// Character Mapping Guide:
//
// 5-bit encoding (5'h00 to 5'h1F) = 32 custom characters
// Input format: 20-bit vector [19:0]
//   - seg_data[19:15] = leftmost digit  (digit 3)
//   - seg_data[14:10] = digit 2
//   - seg_data[9:5]   = digit 1
//   - seg_data[4:0]   = rightmost digit (digit 0)
//
// CUSTOMIZE THE CHARACTER SET:
// Edit the case statement above to define your 32 characters (5'h00 to 5'h1F)
// Each character maps to a 7-bit segment pattern: {g, f, e, d, c, b, a}
//
// Example segment patterns (active low):
//   7'b1000000 = '0' (O shape)
//   7'b1111001 = '1' (right bars)
//   7'b0100100 = '2'
//   7'b0110000 = '3'
//   7'b0011001 = '4'
//   7'b0010010 = '5' or 'S'
//   7'b0000010 = '6' or 'Y'
//   7'b1111000 = '7'
//   7'b0000000 = '8' (all segments)
//   7'b0010000 = '9' or 'g'
//   7'b0001000 = 'A' or 'n'
//   7'b0000011 = 'b' or 'H'
//   7'b1000110 = 'C' or 'L' or 'd'
//   7'b0100001 = 'd' or 'U' or 'W'
//   7'b0000110 = 'E' or 'P'
//   7'b0001110 = 'F' or 'J'
//   7'b1111111 = blank (all off)
//
// ==============================================================
