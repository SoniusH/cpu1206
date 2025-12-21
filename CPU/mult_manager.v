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
    // connected directly from ID/EX rs1 and rs2 data outputs
    input wire [31:0] A,
    input wire [31:0] B,
    // multiplier type
    input wire use_i, // whether to use the multiplier
    input wire [1:0] mult_type_i, //00: Low32, 01: SxS High32, 10: SxU High32, 11: UxU High32
    // destination register address
    // if 0, the instruction is ignored
    // connected directly from ID/EX rd_addr output
    input wire [4:0] rd_addr_i, 
                    
    // outputs
    output wire rd_data, // multiplier result
    //output wire rd_data_2, // used in the case of 2 consecutive instructions of the same operands, 
                            //for upper 32 bits of result
    output wire [4:0] rd_addr,// destination reg addr
    output reg [31:0] rd_addr_flags,
                            // can be used in stall_ctrl_mult to check data hazard
    //output wire [`MULT_PPL_STAGE-1:0] mult_uses // multiplier uses signal
    // as our multipliers are pipelined, we can have multiple instructions in the pipeline
    // the multi-bit mult_uses signal indicates which stage is used
    // thus simplifying the stall control logic
);
    /**************** wires and regs *******************/
    // pipeline registers
    reg [4:0] rd_addr_regs [`MULT_PPL_STAGE-1:0]; // destination reg addrs in pipeline
    reg [1:0] mult_type_regs [`MULT_PPL_STAGE-1:0];

    reg mult_uses [`MULT_PPL_STAGE-1:0];

    wire A_33,B_33;
    wire [65:64] P_66_65;
    wire [31:0] A_act, B_act; // operands actually used, for in some cases there's no mult.
    wire [63:0] P_out;
    wire en_33x33;
    /***************** multiplication processing *******************/
    // temporarily 1'b1, 
    // as when disabled the multiplication in the pipeline cannot be finished
    assign en_33x33 = 1'b1;
    // use the 33rd bit for sign extension, based on mult_type_i
    assign A_33 = use_i & (mult_type_i != 2'b11) & A[31];
    assign B_33 = use_i & (~mult_type_i[1]) & B[31];//use_i & ((mult_type_i==2'b00 || mult_type_i==2'b01)) & B[31];
    // if not using multiplier, set operands to 0
    assign A_act = {32{use_i}} & A;//use_i ? A : 32'b0;
    assign B_act = {32{use_i}} & B;//use_i ? B : 32'b0;
    // assign operands based on mult_type_i
    // instantiate multiplier
    // we use one 33x33 multiplier to cover all cases
    `MULT_MODULE_NAME_33x33 u_mult_33x33(
        .clk(clk), .en(en_33x33),
        .A({A_33,A_act}), .B({B_33,B_act}), .P({P_66_65,P_out})
    )
    // output result selection
    assign rd_data = (mult_type_regs[`MULT_PPL_STAGE-1]==2'b00)? P_out[31:0] : P_out[63:32];
    /****************** pipeline updating *******************/
    // pipeline reg for rd_addr_regs and mult_type_i
    // may need to change to 'generate' syntax later.
    integer i;
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < `MULT_PPL_STAGE; i = i + 1) begin
                rd_addr_regs[i] <= 5'b0;
                mult_type_regs[i] <= 2'b0;
                mult_uses[i] <= 1'b0;
            end
        end else begin
            rd_addr_regs[0] <= {5{use_i}}&rd_addr_i; //use_i ? rd_addr_i : 5'b0;
            mult_type_regs[0] <= mult_type_i;
            mult_uses[0] <= use_i;
            // shift pipeline registers
            for (i = 1; i < `MULT_PPL_STAGE; i = i + 1) begin
                rd_addr_regs[i] <= rd_addr_regs[i-1];
                mult_type_regs[i] <= mult_type_regs[i-1];
                mult_uses[i] <= mult_uses[i-1];
            end
        end
    end
    assign rd_addr = rd_addr_regs[`MULT_PPL_STAGE-1];
    /****************** rd_addr_flags generation *******************/
    // generate rd_addr_flags
    always @(*) begin
        rd_addr_flags = 32'b0;
        for (i = 0; i < `MULT_PPL_STAGE; i = i + 1) begin
            rd_addr_flags[rd_addr_regs[i]] = mult_uses[i];
        end
        rd_addr_flags[rd_addr_i] = use_i;
    end
endmodule