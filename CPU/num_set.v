module num_set (
    input wire clk,
    input wire rst,
    input wire up_button,
    input wire down_button,
    input wire h_button,
    input wire l_button,
    output reg [15:0] data,
    output reg [1:0] dot_seg
);
    reg [3:0]b_1000 = 0, b_100 = 0, b_10 = 0, b_1 = 0;
    reg [1:0] digit_select = 0;  // 0=b_1, 1=b_10, 2=b_100, 3=b_1000

    // data set logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            {b_1000, b_100, b_10, b_1} <= 16'h0;
            digit_select <= 0;
        end else begin
            // the selection of bits according to the button input
            if (h_button) begin
                if (digit_select == 2'd3)
                    digit_select <= 2'd0;
                else
                    digit_select <= digit_select + 1;
            end else if (l_button) begin
                if (digit_select == 2'd0)
                    digit_select <= 2'd3;
                else
                    digit_select <= digit_select - 1;
            end
            // the rise_up logic of each unit
            if (up_button) begin
                case (digit_select)
                    0: b_1 <= (b_1 < 9) ? b_1 + 1 : 0;        
                    1: b_10 <= (b_10 < 9) ? b_10 + 1 : 0;    
                    2: b_100 <= (b_100 < 9) ? b_100 + 1 : 0;         
                    3: b_1000 <= (b_1000 < 9) ? b_1000 + 1 : 0;      
                endcase
            end
            // the decrease logic
            if (down_button) begin
                case (digit_select)
                    0: b_1 <= (b_1 > 0) ? b_1 - 1 : 9;
                    1: b_10 <= (b_10 > 0) ? b_10 - 1 : 9;
                    2: b_100 <= (b_100 > 0) ? b_100 - 1 : 9;         
                    3: b_1000 <= (b_1000 > 0) ? b_1000 - 1 : 9;
                endcase
            end
        end
    end
    
    // refresh output data
    always @(*) begin
        data <= {b_1000, b_100, b_10, b_1};
        dot_seg <= digit_select;
    end
endmodule