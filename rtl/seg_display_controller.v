module seg_display_controller(
    input wire clk,
    input wire reset,
    input wire [19:0] seg_data,  // 4 digits (5 bits each)
    input wire [3:0] dp_data,    // Decimal point per digit (1=on)
    output reg [6:0] seg,        // 7-segment cathodes (a-g)
    output reg dp,               // Decimal point cathode
    output reg [3:0] an          // Anodes for 4 digits
);

    // Refresh counter for multiplexing (~1kHz per digit)
    reg [16:0] refresh_counter;
    wire [1:0] digit_select;
    assign digit_select = refresh_counter[16:15];

    reg [4:0] current_digit;

    // Refresh counter
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            refresh_counter <= 0;
        end else begin
            refresh_counter <= refresh_counter + 1;
        end
    end

    // Anode control (active low)
    always @(*) begin
        case (digit_select)
            2'b00: an = 4'b0111;  // Digit 3 (leftmost)
            2'b01: an = 4'b1011;  // Digit 2
            2'b10: an = 4'b1101;  // Digit 1
            2'b11: an = 4'b1110;  // Digit 0 (rightmost)
            default: an = 4'b1111;
        endcase
    end

    // Decimal point control (active low)
    always @(*) begin
        case (digit_select)
            2'b00: dp = ~dp_data[3];
            2'b01: dp = ~dp_data[2];
            2'b10: dp = ~dp_data[1];
            2'b11: dp = ~dp_data[0];
            default: dp = 1'b1;
        endcase
    end

    // Select current digit from seg_data
    always @(*) begin
        case (digit_select)
            2'b00: current_digit = seg_data[19:15];  // Digit 3
            2'b01: current_digit = seg_data[14:10];  // Digit 2
            2'b10: current_digit = seg_data[9:5];    // Digit 1
            2'b11: current_digit = seg_data[4:0];    // Digit 0
            default: current_digit = 5'd31;
        endcase
    end

    // 7-segment decoder (active low, seg = {g,f,e,d,c,b,a})
    always @(*) begin
        case (current_digit)
            5'd0:  seg = 7'b1000000;  // 0
            5'd1:  seg = 7'b1111001;  // 1
            5'd2:  seg = 7'b0100100;  // 2
            5'd3:  seg = 7'b0110000;  // 3
            5'd4:  seg = 7'b0011001;  // 4
            5'd5:  seg = 7'b0010010;  // 5/S
            5'd6:  seg = 7'b0000010;  // 6
            5'd7:  seg = 7'b1111000;  // 7
            5'd8:  seg = 7'b0000000;  // 8
            5'd9:  seg = 7'b0010000;  // 9/g
            5'd10: seg = 7'b0111111;  // -
            5'd11: seg = 7'b0000110;  // E
            5'd12: seg = 7'b0101111;  // r
            5'd13: seg = 7'b1000111;  // L
            5'd14: seg = 7'b0001001;  // H
            5'd15: seg = 7'b1000001;  // U
            5'd16: seg = 7'b0001100;  // P
            5'd17: seg = 7'b0100011;  // o
            5'd18: seg = 7'b0000011;  // b
            5'd19: seg = 7'b0100001;  // d
            5'd20: seg = 7'b0101011;  // n
            5'd21: seg = 7'b1110001;  // J
            5'd22: seg = 7'b0010001;  // y
            5'd30: seg = 7'b0001011;  // h
            5'd31: seg = 7'b1111111;  // Blank
            default: seg = 7'b1111111;
        endcase
    end
endmodule
