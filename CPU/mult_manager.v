`timescale 1ns/1ps
/*
    This module manages multipliers with pipelining.
*/
`include "defines.vh"
module mult_manager(
    input wire clk,
    input wire rst,
    // inputs
    // multiplier operands
    input wire [31:0] A,
    input wire [31:0] B,
    // multiplier type
    input wire [1:0] mult_type, //00: Low32, 01: SxS High32, 10: SxU High32, 11: UxU High32
    input wire use_i, // whether to use the multiplier
    // destination register address
    // if 0, the instruction is ignored
    input wire [4:0] rd_addr_i, 
                    
    // outputs
    output wire rd_data, // multiplier result
    //output wire rd_data_2, // used in the case of 2 consecutive instructions of the same operands, 
                            //for upper 32 bits of result
    output reg [4:0] rd_addrs [`MULT_PPL_STAGE-1:0] // destination reg addrs in pipeline
                            // can be used in stall_ctrl_mult to check data hazard
    output wire [`MULT_PPL_STAGE-1:0] uses // multiplier uses signal
    // as our multipliers are pipelined, we can have multiple instructions in the pipeline
    // the multi-bit uses signal indicates which stage is uses
    // thus simplifying the stall control logic
);
    // pipeline registers
    reg [1:0] mult_type_reg [`MULT_PPL_STAGE-1:0];
    wire [31:0] A_SxS, B_SxS, P_SxS,
                A_SxU, B_SxU, P_SxU,
                A_UxU, B_UxU, P_UxU;
    wire en_SxS, en_SxU, en_UxU;
    // temporarily 1'b1, 
    // as when disabled the multiplication in the pipeline cannot be finished
    assign en_SxS = 1'b1;
    assign en_SxU = 1'b1;
    assign en_UxU = 1'b1;
    // used when consecutive instructions use the same operands
    // reg [31:0] rd_data_HI_LO;
    // reg [1:0] rd_data_op_flag; // 2'b00: LO SxS, 2'b01: HI SxS, 2'b10: HI SxU, 2'b11: HI UxU
    // assign operands based on mult_type
    // instantiate multipliers
    `MULT_MODULE_NAME_SxS u_mult_sxs(
        .clk(clk), .en(en_SxS),
        .A(A_SxS), .B(B_SxS), .P(P_SxS)
    );
    `MULT_MODULE_NAME_SxU u_mult_sxu(
        .clk(clk), .en(en_SxU),
        .A(A_SxU), .B(B_SxU), .P(P_SxU)
    );
    `MULT_MODULE_NAME_UxU u_mult_uxu(
        .clk(clk), .en(en_UxU),
        .A(A_UxU), .B(B_UxU), .P(P_UxU)
    );
    // input operand selection
    assign A_SxS = {32{use_i}}&{32{~mult_type[1]}}&$signed(A);//(mult_type==2'b00 || mult_type==2'b01)? $signed(A) : 32'b0;
    assign B_SxS = {32{use_i}}&{32{~mult_type[1]}}&$signed(B);//(mult_type==2'b00 || mult_type==2'b01)? $signed(B) : 32'b0;
    assign A_SxU = {32{use_i}}&{32{(mult_type==2'b10)}}&$signed(A);//(mult_type==2'b10)? $signed(A) : 32'b0;
    assign B_SxU = {32{use_i}}&{32{(mult_type==2'b10)}}&$signed(B);//(mult_type==2'b10)? B : 32'b0;
    assign A_UxU = {32{use_i}}&{32{(mult_type==2'b11)}}&A;//(mult_type==2'b11)? A : 32'b0;
    assign B_UxU = {32{use_i}}&{32{(mult_type==2'b11)}}&B;//(mult_type==2'b11)? B : 32'b0;
    // output result selection
    assign rd_data = mult_type_reg[`MULT_PPL_STAGE-1][1] ?
                     (mult_type_reg[`MULT_PPL_STAGE-1][0]? P_UxU[63:32] : P_SxU[63:32]) :
                     (mult_type_reg[`MULT_PPL_STAGE-1][0]? P_SxS[63:32] : P_SxS[31:0]);
    /*
    assign rd_data = (mult_type_reg[`MULT_PPL_STAGE-1]==2'b00)? P_SxS[31:0] :
                     (mult_type_reg[`MULT_PPL_STAGE-1]==2'b01)? P_SxS[63:32] :
                     (mult_type_reg[`MULT_PPL_STAGE-1]==2'b10)? P_SxU[63:32] :
                     (mult_type_reg[`MULT_PPL_STAGE-1]==2'b11)? P_UxU[63:32] :
                     32'b0;
    */
    // pipeline reg for rd_addrs and mult_type
    integer i;
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < `MULT_PPL_STAGE; i = i + 1) begin
                rd_addrs[i] <= 5'b0;
                mult_type_reg[i] <= 2'b0;
                uses[i] <= 1'b0;
            end
        end else begin
            rd_addrs[0] <= {5{use_i}}&rd_addr_i; //use_i ? rd_addr_i : 5'b0;
            mult_type_reg[0] <= mult_type;
            uses[0] <= use_i;
            // shift pipeline registers
            for (i = 1; i < `MULT_PPL_STAGE; i = i + 1) begin
                rd_addrs[i] <= rd_addrs[i-1];
                mult_type_reg[i] <= mult_type_reg[i-1];
                uses[i] <= uses[i-1];
            end
        end
    end

endmodule