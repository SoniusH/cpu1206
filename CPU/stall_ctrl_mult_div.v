`timescale 1ns/1ps
`include "defines.vh"
/*
    This module generates stalling control signal for multiplication operations.
    It generates stall signals based on the status of the multiplication unit
    and current instruction in the ID stage of the pipeline to prevent Data Hazard.
*/
module stall_ctrl_mult_div(
    input wire clk,
    input wire rst,
    // from mult_manager and div_manager
    input wire [31:0] rd_addr_flags_mult_i, // rd from mult_manager
    input wire [31:0] rd_addr_flags_div_i, // rd from div_manager
    // from ID stage
    // rs1
    input wire rs1_re_id_i, 
    input wire [4:0] rs1_addr_id_i,
    // rs2
    input wire rs2_re_id_i, 
    input wire [4:0] rs2_addr_id_i,
    // rd
    input wire rd_we_id_i, 
    input wire [4:0] rd_addr_id_i,
    // to pipeline control
    output reg stall // stall signal to pipeline control
);
    wire [31:0] rd_addr_flags_comb;
    assign rd_addr_flags_comb = rd_addr_flags_mult_i | rd_addr_flags_div_i;
    always @(*) begin
        stall = 1'b0;
        // check for data hazard with multiplier pipeline stages
        if(rs1_re_id_i && rd_addr_flags_comb[rs1_addr_id_i])begin
            stall = 1'b1;
        end 
        if(rs2_re_id_i && rd_addr_flags_comb[rs2_addr_id_i])begin
            stall = 1'b1;
        end 
        if(rd_we_id_i && rd_addr_flags_comb[rd_addr_id_i])begin
            stall = 1'b1;
        end 
    end
endmodule