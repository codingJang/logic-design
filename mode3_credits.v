module mode3_credits(
    input wire clk,
    input wire reset,
    input wire active,
    output reg [15:0] led,
    output reg [15:0] seg_data
);

    // Team member names
    // Format: Member Number (1 digit) + 3 initials
    // J=0xF (custom), Y=0x6, S=0x5, W=0xD (looks like U)

    // Member 1: 장예준 (Jang Ye Jun) -> 1JYJ
    localparam [15:0] MEMBER1 = 16'h1F66;  // "1" "J" "Y" "J"

    // Member 2: 홍연수 (Hong Yeon Su) -> 2HYS
    localparam [15:0] MEMBER2 = 16'h2B65;  // "2" "H" "Y" "S"

    // Member 3: 변준우 (Byeon Jun U) -> 3BJW
    localparam [15:0] MEMBER3 = 16'h3BFD;  // "3" "B" "J" "W"

    // Note: Only 3 team members provided, MEMBER4 will cycle back to MEMBER1
    localparam [15:0] MEMBER4 = 16'h0000;  // Blank/unused

    // State for cycling through members
    reg [1:0] member_index;  // 0-2 for 3 members (0-3 if 4 members)

    // Clock divider for 3 second period
    reg [27:0] clk_counter;
    wire clk_3s;
    assign clk_3s = (clk_counter == 28'd300_000_000);  // Adjust for your clock frequency (assuming 100MHz)

    // Clock divider
    always @(posedge clk or posedge reset) begin
        if (reset || !active) begin
            clk_counter <= 0;
        end else begin
            if (clk_counter == 28'd300_000_000) begin
                clk_counter <= 0;
            end else begin
                clk_counter <= clk_counter + 1;
            end
        end
    end

    // Member cycling logic
    always @(posedge clk or posedge reset) begin
        if (reset || !active) begin
            member_index <= 0;
            seg_data <= MEMBER1;
            led <= 16'b0;
        end else begin
            if (clk_3s) begin
                // Cycle to next member (3 members total)
                if (member_index == 2)
                    member_index <= 0;
                else
                    member_index <= member_index + 1;
            end

            // Display current member's initials
            case (member_index)
                2'd0: seg_data <= MEMBER1;
                2'd1: seg_data <= MEMBER2;
                2'd2: seg_data <= MEMBER3;
                default: seg_data <= MEMBER1;
            endcase

            // No LED activity in credits mode
            led <= 16'b0;
        end
    end

endmodule


// ==============================================================
// NOTES FOR CUSTOMIZATION:
// ==============================================================
//
// To customize this module with your actual team member names:
//
// 1. For each team member, determine the initials:
//    - Last name initial (uppercase)
//    - First name initial (lowercase)
//    - Second name initial (lowercase)
//
// 2. Map each character to a 4-bit hex value for 7-segment display:
//    Numbers: 0-9 = 0x0-0x9
//    Letters: You need to define how each letter looks on 7-segment
//
//    Common mappings:
//    A/a = 0xA, B/b = 0xB, C/c = 0xC, D/d = 0xD
//    E/e = 0xE, F/f = 0xF, G/g = 0x9, H/h = 0xB
//    L/l = 0xC, N/n = 0xA, O/o = 0x0, P/p = 0xE
//    S/s = 0x5, U/u = 0xD, etc.
//
// 3. Update the MEMBER1-4 parameters with your team's data:
//    localparam [15:0] MEMBER1 = 16'h[digit][initial1][initial2][initial3];
//
// Example:
//    Name: Hong Gill Dong (1st member)
//    Format: 1 H g d
//    Hex mapping: 1=0x1, H=0xB, g=0x9, d=0xD
//    Result: localparam [15:0] MEMBER1 = 16'h1B9D;
//
// ==============================================================
