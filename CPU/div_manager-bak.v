`timescale 1ns/1ps
/*
    This module manages dividers with pipelining.
    But to save LUT and FF resources, 
    the divider won't process more than 1 division simutaneously,
    thus saving rd_addr FFs and 5-32 decoder LUTs.
*/
`include "defines.vh"
module div_manager(
    input wire clk,
    input wire rst,
    // inputs
    // divider operands
    // connected directly from ID/EX rs1 and rs2 data outputs
    input wire [31:0] dividend,
    input wire [31:0] divisor,
    // divider type
    input wire div_sign_i, //signed or unsigned division
    input wire div_result_i, //put out quotient or remainder
    // whether to use the divider
    input wire use_i,
    // destination register address
    // if 0, the instruction is ignored
    // connected directly from ID/EX rd_addr output
    input wire [4:0] rd_addr_i, 
                    
    // outputs
    output wire [4:0] rd_addr,// destination reg addr
    output wire [31:0] rd_data, // divider result
    output reg [31:0] rd_addr_flags // can be used in stall_ctrl_div to check data hazard

    // as our dividers are pipelined, we can have multiple instructions in the pipeline
    // the multi-bit div_uses signal indicates which stage is used
    // thus simplifying the stall control logic(by used in rd_addr_flags generation)
);
    /**************** wires and regs *******************/
    // pipeline registers
    reg [4:0] rd_addr_regs [`MULT_PPL_STAGE-1:0]; // destination reg addrs in pipeline
    //reg div_sign_regs [`MULT_PPL_STAGE-1:0];
    reg div_result_regs [`MULT_PPL_STAGE-1:0];

    reg div_uses [`MULT_PPL_STAGE-1:0];

    wire dividend_33, divisor_33, quotient_33, remainder_33;
    wire [31:0] dividend_act, divisor_act; // operands actually used, for in some cases there's no div.
    wire [31:0] quotient, remainder;
    wire en_div;
    /***************** division processing *******************/
    // temporarily 1'b1, 
    // as when disabled the division in the pipeline cannot be finished
    assign en_div = 1'b1;
    // assign sign extension bits based on div_sign_i
    assign dividend_33 = use_i & (div_sign_i==DIV_TYPE_SIGNED) & dividend[31];
    assign divisor_33 = use_i & (div_sign_i==DIV_TYPE_SIGNED) & divisor[31];
    // if not using divider, set operands to 0
    assign dividend_act = {32{use_i}} & dividend;//use_i ? dividend : 32'b0;
    assign divisor_act = {32{use_i}} & divisor;//use_i ? divisor : 32'b0;
    // we use 33x33 divider to handle unsigned cases
    `DIV_MODULE_NAME u_div(
        .clk(clk), .en(en_div),
        .dividend({dividend_33,dividend_act}), .divisor({divisor_33,divisor_act}), 
        .quotient({quotient_33,quotient}), .remainder({remainder_33,remainder})
    );

    // output result selection
    assign rd_data = (div_result_regs[`MULT_PPL_STAGE-1]==DIV_TYPE_QUOTIENT) ? quotient : remainder;
    /****************** pipeline registers *******************/
    // pipeline reg for rd_addr_regs and div_type_i
    integer i;
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < `MULT_PPL_STAGE; i = i + 1) begin
                rd_addr_regs[i] <= 5'b0;
                div_result_regs[i] <= 1'b0;
                div_uses[i] <= 1'b0;
            end
        end else begin
            rd_addr_regs[0] <= {5{use_i}}&rd_addr_i; //use_i ? rd_addr_i : 5'b0;
            div_result_regs[0] <= div_result_i;
            div_uses[0] <= use_i;
            // shift pipeline registers
            for (i = 1; i < `MULT_PPL_STAGE; i = i + 1) begin
                rd_addr_regs[i] <= rd_addr_regs[i-1];
                div_result_regs[i] <= div_result_regs[i-1];
                div_uses[i] <= div_uses[i-1];
            end
        end
    end
    assign rd_addr = rd_addr_regs[`MULT_PPL_STAGE-1];
    /****************** rd_addr_flags generation *******************/
    // generate rd_addr_flags
    always @(*) begin
        rd_addr_flags = 32'b0;
        for (i = 0; i < `MULT_PPL_STAGE; i = i + 1) begin
            rd_addr_flags[rd_addr_regs[i]] = div_uses[i];
        end
    end
endmodule