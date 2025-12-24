`timescale 1ns/1ps
/*
    This module is for solving RAW data hazard (reg case).
    It forwards data from EX, MEM and WB to ID stage.
    Schematic:

          EX stage
             |
         -----------
        |           |
*/
module fw4RAW_reg(
    input wire rst,

    // from ID stage and regs
    input wire rs1_re_id_i,
    input wire [4:0] rs1_addr_id_i,
    input wire [31:0] rs1_data_from_reg_i,

    input wire rs2_re_id_i,
    input wire [4:0] rs2_addr_id_i,
    input wire [31:0] rs2_data_from_reg_i,

    // from EX stage
    input wire rd_we_ex_i,
    input wire [4:0] rd_addr_ex_i,
    input wire [31:0] rd_data_ex_i,

    // from MEM stage
    input wire rd_we_mem_i,
    input wire [4:0] rd_addr_mem_i,
    input wire [31:0] rd_data_mem_i,

    // from WB stage
    input wire rd_we_wb_i,
    input wire [4:0] rd_addr_wb_i,
    input wire [31:0] rd_data_wb_i,

    // back to ID stage
    output wire [31:0] rs1_data_id,
    output wire [31:0] rs2_data_id
);
    // MUX connected with priority
    assign rs1_data_id = rst ? 32'b0 :
                         (rs1_re_id_i && (rs1_addr_id_i != 5'b0) && rd_we_ex_i && (rs1_addr_id_i == rd_addr_ex_i)) ? rd_data_ex_i :
                         (rs1_re_id_i && (rs1_addr_id_i != 5'b0) && rd_we_mem_i && (rs1_addr_id_i == rd_addr_mem_i)) ? rd_data_mem_i :
                         (rs1_re_id_i && (rs1_addr_id_i != 5'b0) && rd_we_wb_i && (rs1_addr_id_i == rd_addr_wb_i)) ? rd_data_wb_i :
                         rs1_data_from_reg_i;

    assign rs2_data_id = rst ? 32'b0 :
                         (rs2_re_id_i && (rs2_addr_id_i != 5'b0) && rd_we_ex_i && (rs2_addr_id_i == rd_addr_ex_i)) ? rd_data_ex_i :
                         (rs2_re_id_i && (rs2_addr_id_i != 5'b0) && rd_we_mem_i && (rs2_addr_id_i == rd_addr_mem_i)) ? rd_data_mem_i :
                         (rs2_re_id_i && (rs2_addr_id_i != 5'b0) && rd_we_wb_i && (rs2_addr_id_i == rd_addr_wb_i)) ? rd_data_wb_i :
                         rs2_data_from_reg_i;
endmodule