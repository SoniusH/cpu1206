module seg_display (
    input wire clk,
    input wire [15:0]data,
    input wire [2:0]dot_seg,
    output reg [3:0]seg_an,
    output reg [7:0]seg_seg
);
    integer clk_cnt =0;
    reg clk_400Hz = 0;
    reg [3:0]seg_an_ctrl = 4'b1110;
    reg [3:0]seg_ctrl;
    //to get a 400Hz display signal
    always@ (posedge clk)
        if (clk_cnt == 17'd124999) begin
            clk_cnt <= 0;
            clk_400Hz <= ~clk_400Hz;
        end else clk_cnt <= clk_cnt +1;
    //the selection of anode
    always@ (posedge clk_400Hz) begin
        seg_an_ctrl <= {seg_an_ctrl[2:0],seg_an_ctrl[3]};
        seg_an <= seg_an_ctrl;
    end
    //to load the matching data and set dot to make each time unit clear
    always@ (*)
        case (seg_an_ctrl)
            4'b1110 : begin 
                          seg_ctrl <= data[3:0];
                          seg_seg[7] <= (dot_seg == 0) ? 0 : 1;
                      end
            4'b1101 : begin
                          seg_ctrl <= data[7:4];
                          seg_seg[7] <= (dot_seg == 1) ? 0 : 1;
                      end
            4'b1011 : begin
                          seg_ctrl <= data[11:8];
                          seg_seg[7] <= (dot_seg == 2) ? 0 : 1;
                      end
            4'b0111 : begin
                          seg_ctrl <= data[15:12];
                          seg_seg[7] <= (dot_seg == 3) ? 0 : 1;
                      end
            default : begin
                          seg_ctrl <= 4'hf;
                      end
        endcase
    //7-segment for the display of number 0~9
    always@ (*)
        case (seg_ctrl)
            4'h0 : seg_seg[6:0] <= 7'b100_0000;
            4'h1 : seg_seg[6:0] <= 7'b111_1001;
            4'h2 : seg_seg[6:0] <= 7'b010_0100;
            4'h3 : seg_seg[6:0] <= 7'b011_0000;
            4'h4 : seg_seg[6:0] <= 7'b001_1001;
            4'h5 : seg_seg[6:0] <= 7'b001_0010;
            4'h6 : seg_seg[6:0] <= 7'b000_0010;
            4'h7 : seg_seg[6:0] <= 7'b111_1000;
            4'h8 : seg_seg[6:0] <= 7'b000_0000;
            4'h9 : seg_seg[6:0] <= 7'b001_0000;
            default : seg_seg[6:0] <= 7'b111_1111;
        endcase
endmodule