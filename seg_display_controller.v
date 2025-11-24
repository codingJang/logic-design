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

    // Enhanced 7-segment decoder (cathode control - active low for common anode display)
    // Segment mapping: {g, f, e, d, c, b, a}
    always @(*) begin
        case (current_digit)
            // Numbers 0-9
            4'h0: seg = 7'b1000000; // 0 - displays "O" shape
            4'h1: seg = 7'b1111001; // 1 - right vertical bars
            4'h2: seg = 7'b0100100; // 2 - standard 2
            4'h3: seg = 7'b0110000; // 3 - standard 3
            4'h4: seg = 7'b0011001; // 4 - standard 4
            4'h5: seg = 7'b0010010; // 5 - displays "S" shape
            4'h6: seg = 7'b0000010; // 6 - displays "Y" approximation
            4'h7: seg = 7'b1111000; // 7 - standard 7
            4'h8: seg = 7'b0000000; // 8 - all segments (full)
            4'h9: seg = 7'b0010000; // 9 - displays "g" shape

            // Letters A-F (custom mappings for project)
            4'hA: seg = 7'b0001000; // A - also used for 'n'
            4'hB: seg = 7'b0000011; // b - also used for 'H'
            4'hC: seg = 7'b1000110; // C - also used for 'L', 'd'
            4'hD: seg = 7'b0100001; // d - also used for 'U', 'W'
            4'hE: seg = 7'b0000110; // E - also used for 'P'
            4'hF: seg = 7'b0001110; // F - displays 'J' approximation

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
// Character Mapping Guide for this project:
//
// Numbers:
// 0-9: Standard digit displays
// Special: 5 = "S" shape, 6 = "Y" approximation, 9 = "g" shape
//
// Letters (hex A-F):
// 4'hA (10): 'A', 'n' - upper segments with middle bar
// 4'hB (11): 'b', 'H' - lower segments + middle bar
// 4'hC (12): 'C', 'L', 'd' - left-side segments
// 4'hD (13): 'd', 'U', 'W' - bottom U shape
// 4'hE (14): 'E', 'P' - left segments with top/middle
// 4'hF (15): 'F', 'J' - best J approximation available
//
// Team Member Displays:
// Member 1: 1JYJ -> 16'h1F66 (1, J=F, Y=6, J=6)
// Member 2: 2HYS -> 16'h2B65 (2, H=B, Y=6, S=5)
// Member 3: 3BJW -> 16'h3BFD (3, B=B, J=F, W=D)
//
// Mode 1 Words:
// "good": 16'h900D (g=9, o=0, o=0, d=D)
// "gogo": 16'h9090 (g=9, o=0, g=9, o=0)
// "-Err": 16'hFEEE (F=blank/-, E, r=E, r=E)
// "LOSE": 16'hC05E (L=C, O=0, S=5, E=E)
// "XS YB": Strike/Ball display (X,Y are counts 0-4)
//
// Mode 2 Words:
// "UP": 16'h--DE (U=D, P=E)
// "dn": 16'h--CA (d=C, n=A)
// "good": 16'h900D (same as Mode 1)
//
// ==============================================================
