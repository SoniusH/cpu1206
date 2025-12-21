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
    input wire div_result_type_i, //put out quotient or remainder
    // whether to use the divider
    input wire use_i,
    // destination register address
    // if 0, the instruction is ignored
    // connected directly from ID/EX rd_addr output
    input wire [4:0] rd_addr_i, 
                    
    // outputs
    output wire rd_we,
    output reg [4:0] rd_addr,// destination reg addr
    output wire [31:0] rd_data, // divider result
    //output wire busy,
    output wire finish
    //output reg [31:0] rd_addr_flags // can be used in stall_ctrl_div to check data hazard
);
    /**************** wires and regs *******************/
    // pipeline registers
    reg [`DIV_PPL_STAGE_LOG2-1:0] counter;
    reg div_result_type_reg;

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
    assign rd_data = (div_result_type_reg==DIV_TYPE_QUOTIENT) ? quotient : remainder;
    always @(posedge clk) begin
        if (rst) begin
            counter <= 0;
        end else begin
            if (use_i && counter == 0) begin
                counter <= `DIV_PPL_STAGE;
            end else if (counter != 0) begin
                counter <= counter - 1;
            end
        end
    end
    assign finish = (counter == 1) ? 1'b1 : 1'b0;
    assign rd_we = finish;
    //assign busy = (counter != 0) ? 1'b1 : 1'b0;
    always @(posedge clk) begin
        if (rst) begin
            rd_addr <= 5'b0;
            div_result_type_reg <= DIV_TYPE_QUOTIENT;
        end else begin
            if(use_i && rd_addr == 5'b0) begin
                rd_addr <= rd_addr_i;
                div_result_type_reg <= div_result_type_i;
            end else if (finish) begin
                rd_addr <= 5'b0;
                div_result_type_reg <= DIV_TYPE_QUOTIENT;
            end
        end
    end
    /****************** rd_addr_flags generation *******************/
    // generate rd_addr_flags
    always @(*) begin
        rd_addr_flags = 32'b0;
        for (i = 0; i < `MULT_PPL_STAGE; i = i + 1) begin
            rd_addr_flags[rd _addr_regs[i]] = div_uses[i];
        end
        rd_addr_flags[rd_addr_i] = use_i;
    end
endmodule