module seg_display_controller(
    input wire clk,
    input wire reset,
    input wire [15:0] seg_data,  // 4 hex digits to display
    output reg [6:0] seg,         // 7-segment cathodes (a-g)
    output reg [3:0] an           // 4 anodes for 4 digits
);

    // Refresh counter for multiplexing (approximately 1kHz refresh per digit)
    reg [16:0] refresh_counter;
    wire [1:0] digit_select;
    assign digit_select = refresh_counter[16:15];  // Select which digit to display

    // Current digit data to decode
    reg [3:0] current_digit;

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
            2'b00: current_digit = seg_data[15:12];  // Digit 3 (leftmost)
            2'b01: current_digit = seg_data[11:8];   // Digit 2
            2'b10: current_digit = seg_data[7:4];    // Digit 1
            2'b11: current_digit = seg_data[3:0];    // Digit 0 (rightmost)
            default: current_digit = 4'h0;
        endcase
    end

    // 7-segment decoder (cathode control - active low for common anode display)
    // Segment mapping: {g, f, e, d, c, b, a}
    always @(*) begin
        case (current_digit)
            4'h0: seg = 7'b1000000; // 0
            4'h1: seg = 7'b1111001; // 1
            4'h2: seg = 7'b0100100; // 2
            4'h3: seg = 7'b0110000; // 3
            4'h4: seg = 7'b0011001; // 4
            4'h5: seg = 7'b0010010; // 5
            4'h6: seg = 7'b0000010; // 6
            4'h7: seg = 7'b1111000; // 7
            4'h8: seg = 7'b0000000; // 8
            4'h9: seg = 7'b0010000; // 9
            4'hA: seg = 7'b0001000; // A (also used for 'n', 'B')
            4'hB: seg = 7'b0000011; // b (also used for 'H')
            4'hC: seg = 7'b1000110; // C (also used for 'L')
            4'hD: seg = 7'b0100001; // d (also used for 'U')
            4'hE: seg = 7'b0000110; // E (also used for 'P')
            4'hF: seg = 7'b1111111; // Blank (all segments off)
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
// Common character mappings used in this project:
// 0-9: Standard digits
// A: 0x0001000 (used for 'n', 'B' approximation)
// b: 0x0000011 (used for 'H' approximation)
// C: 0x1000110 (used for 'L' approximation)
// d: 0x0100001 (used for 'U' approximation)
// E: 0x0000110 (used for 'P' approximation)
// F: 0x1111111 (blank/off)
//
// Special display words:
// "good": 9, 0, 0, d
// "gogo": 9, 0, 9, 0
// "-Err": -, E, r, r
// "LOSE": L, 0, S, E
// "UP": U, P
// "dn": d, n
//
// ==============================================================
