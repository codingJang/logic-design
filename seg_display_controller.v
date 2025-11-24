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
            default: current_digit = 5'h00;
        endcase
    end

    // Enhanced 7-segment decoder (cathode control - active low for common anode display)
    // Segment mapping: {g, f, e, d, c, b, a}
    // 5-bit encoding allows 32 custom characters (5'h00 to 5'h1F)
    always @(*) begin
        case (current_digit)
            // Character 0-15 (first 16 characters)
            5'h00: seg = 7'b1111111; // 00 - PLACEHOLDER - customize as needed
            5'h01: seg = 7'b1111111; // 01 - PLACEHOLDER - customize as needed
            5'h02: seg = 7'b1111111; // 02 - PLACEHOLDER - customize as needed
            5'h03: seg = 7'b1111111; // 03 - PLACEHOLDER - customize as needed
            5'h04: seg = 7'b1111111; // 04 - PLACEHOLDER - customize as needed
            5'h05: seg = 7'b1111111; // 05 - PLACEHOLDER - customize as needed
            5'h06: seg = 7'b1111111; // 06 - PLACEHOLDER - customize as needed
            5'h07: seg = 7'b1111111; // 07 - PLACEHOLDER - customize as needed
            5'h08: seg = 7'b1111111; // 08 - PLACEHOLDER - customize as needed
            5'h09: seg = 7'b1111111; // 09 - PLACEHOLDER - customize as needed
            5'h0A: seg = 7'b1111111; // 0A - PLACEHOLDER - customize as needed
            5'h0B: seg = 7'b1111111; // 0B - PLACEHOLDER - customize as needed
            5'h0C: seg = 7'b1111111; // 0C - PLACEHOLDER - customize as needed
            5'h0D: seg = 7'b1111111; // 0D - PLACEHOLDER - customize as needed
            5'h0E: seg = 7'b1111111; // 0E - PLACEHOLDER - customize as needed
            5'h0F: seg = 7'b1111111; // 0F - PLACEHOLDER - customize as needed

            // Character 16-31 (next 16 characters)
            5'h10: seg = 7'b1111111; // 10 - PLACEHOLDER - customize as needed
            5'h11: seg = 7'b1111111; // 11 - PLACEHOLDER - customize as needed
            5'h12: seg = 7'b1111111; // 12 - PLACEHOLDER - customize as needed
            5'h13: seg = 7'b1111111; // 13 - PLACEHOLDER - customize as needed
            5'h14: seg = 7'b1111111; // 14 - PLACEHOLDER - customize as needed
            5'h15: seg = 7'b1111111; // 15 - PLACEHOLDER - customize as needed
            5'h16: seg = 7'b1111111; // 16 - PLACEHOLDER - customize as needed
            5'h17: seg = 7'b1111111; // 17 - PLACEHOLDER - customize as needed
            5'h18: seg = 7'b1111111; // 18 - PLACEHOLDER - customize as needed
            5'h19: seg = 7'b1111111; // 19 - PLACEHOLDER - customize as needed
            5'h1A: seg = 7'b1111111; // 1A - PLACEHOLDER - customize as needed
            5'h1B: seg = 7'b1111111; // 1B - PLACEHOLDER - customize as needed
            5'h1C: seg = 7'b1111111; // 1C - PLACEHOLDER - customize as needed
            5'h1D: seg = 7'b1111111; // 1D - PLACEHOLDER - customize as needed
            5'h1E: seg = 7'b1111111; // 1E - PLACEHOLDER - customize as needed
            5'h1F: seg = 7'b1111111; // 1F - PLACEHOLDER - customize as needed

            default: seg = 7'b1111111; // Blank (all segments off)
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
