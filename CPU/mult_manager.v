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
    input wire use, // whether to use the multiplier
    // destination register address
    // if 0, the instruction is ignored
    input wire [4:0] rd_addr_i, 
                    
    // outputs
    output wire rd_data, // multiplier result
    output wire rd_data_2, // used in the case of 2 consecutive instructions of the same operands, 
                            //for upper 32 bits of result
    output reg [4:0] rd_addrs [`MULT_PPL_STAGE-1:0] // destination reg addrs in pipeline
                            // can be used in stall_ctrl_mult to check data hazard
    output wire [`MULT_PPL_STAGE-1:0] busy // multiplier busy signal
    // as our multipliers are pipelined, we can have multiple instructions in the pipeline
    // the multi-bit busy signal indicates which stage is busy
    // thus simplifying the stall control logic
);
    reg [1:0] mult_type_reg [`MULT_PPL_STAGE-1:0];
    wire [31:0] A_SxS, B_SxS, P_SxS,
                A_SxU, B_SxU, P_SxU,
                A_UxU, B_UxU, P_UxU;
    // instantiate multipliers
    `MULT_MODULE_NAME_SxS u_mult_sxs(
        .clk(clk), .en(1'b1),
        .A(A_SxS), .B(B_SxS), .P(P_SxS)
    );
    `MULT_MODULE_NAME_SxU u_mult_sxu(
        .clk(clk), .en(1'b1),
        .A(A_SxU), .B(B_SxU), .P(P_SxU)
    );
    `MULT_MODULE_NAME_UxU u_mult_uxu(
        .clk(clk), .en(1'b1),
        .A(A_UxU), .B(B_UxU), .P(P_UxU)
    );
    // pipeline reg for rd_addrs and mult_type
    integer i;
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < `MULT_PPL_STAGE; i = i + 1) begin
                rd_addrs[i] <= 5'b0;
                mult_type_reg[i] <= 2'b0;
                busy[i] <= 1'b0;
            end
        end else begin
            rd_addrs[0] <= {5{use}}&rd_addr_i; //use ? rd_addr_i : 5'b0;
            mult_type_reg[0] <= mult_type;
            busy[0] <= use;
            // shift pipeline registers
            for (i = 1; i < `MULT_PPL_STAGE; i = i + 1) begin
                rd_addrs[i] <= rd_addrs[i-1];
                mult_type_reg[i] <= mult_type_reg[i-1];
                busy[i] <= busy[i-1];
            end
        end
    end

endmodule