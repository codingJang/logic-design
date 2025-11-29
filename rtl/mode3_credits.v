module mode3_credits(
    input wire clk,
    input wire reset,
    input wire active,
    output reg [15:0] led,
    output reg [19:0] seg_data,
    output wire [3:0] dp_data
);

    // Decimal point on leftmost digit only
    assign dp_data = 4'b1000;

    // Character codes
    localparam C_1 = 5'd1;
    localparam C_2 = 5'd2;
    localparam C_3 = 5'd3;
    
    localparam C_J = 5'd21;
    localparam C_y = 5'd22;
    localparam C_h = 5'd14;
    localparam C_b = 5'd18;
    localparam C_S = 5'd5;

    // Member display patterns
    localparam [19:0] MEMBER1 = {C_1, C_J, C_y, C_J};
    localparam [19:0] MEMBER2 = {C_2, C_h, C_y, C_S};
    localparam [19:0] MEMBER3 = {C_3, C_b, C_J, C_3};

    reg [1:0] member_index;

    // 3 second timer (100MHz: 300,000,000 cycles)
    reg [28:0] clk_counter;
    wire clk_3s;
    assign clk_3s = (clk_counter == 29'd299_999_999);

    // Clock divider
    always @(posedge clk or posedge reset) begin
        if (reset || !active) begin
            clk_counter <= 0;
        end else begin
            if (clk_counter == 29'd299_999_999) begin
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
                if (member_index == 2)
                    member_index <= 0;
                else
                    member_index <= member_index + 1;
            end

            case (member_index)
                2'd0: seg_data <= MEMBER1;
                2'd1: seg_data <= MEMBER2;
                2'd2: seg_data <= MEMBER3;
                default: seg_data <= MEMBER1;
            endcase

            led <= 16'b0;
        end
    end

endmodule
