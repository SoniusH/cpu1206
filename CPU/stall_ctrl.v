`timescale 1ns/1ps
`include "defines.vh"
/*
    This module generates stalling control signal 
    for multiplication and division operations and MEM LOAD.
    It generates stall signals based on the status of 
    the multiplication and division units and the load instruction in EX stage
    and current instruction in the ID stage of the pipeline to prevent Data Hazard.
*/
module stall_ctrl(
    input wire clk,
    input wire rst,
    // from mult_manager and div_manager
    input wire [31:0] rd_addr_flags_mult_i, // rd from mult_manager
    input wire [31:0] rd_addr_flags_div_i, // rd from div_manager
    input wire [4:0] rd_addr_I_LOAD_i, // rd from load instruction, connected from EX stage
    input wire ram_re_I_LOAD_i, // whether the current instruction is among the 5 load instructions
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
        // check for data hazard with multiplier and divider pipeline stages and MEM I_LOAD
        if(rs1_re_id_i && (rd_addr_flags_comb[rs1_addr_id_i] || (ram_re_I_LOAD_i && rs1_addr_id_i == rd_addr_I_LOAD_i)))begin
            stall = 1'b1;
        end 
        if(rs2_re_id_i && (rd_addr_flags_comb[rs2_addr_id_i] || (ram_re_I_LOAD_i && rs2_addr_id_i == rd_addr_I_LOAD_i)))begin
            stall = 1'b1;
        end 
        if(rd_we_id_i && rd_addr_flags_comb[rd_addr_id_i])begin
            stall = 1'b1;
        end 
    end
endmodule