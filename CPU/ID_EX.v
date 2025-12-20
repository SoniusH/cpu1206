`timescale 1ns/1ps
`include "defines.vh"
module ID_EX(
    input wire clk,
    input wire rst,

    // stall and flush
    input stall,
    input flush,

    input wire [`PC_WIDTH-1:0] pc_i, // temporily 10-bit in width,
    //input wire [2:0] type_i, // 6 types
    input wire [6:0] opcode_i,
    input wire [6:0] funct7_i,
    input wire [2:0] funct3_i,

    input wire [31:0] imm_i,
    // rs1
    input wire [31:0] rs1_data_i,
    // rs2
    input wire [31:0] rs2_data_i,
    // rd
    input wire rd_we_i,
    input wire [4:0] rd_addr_i,

    //output wire [2:0] type, // 6 types
    //output reg [3:0] op_sel,

    output reg [`PC_WIDTH-1:0] pc,
    output reg [6:0] opcode,
    output reg [6:0] funct7,
    output reg [2:0] funct3,

    output reg [31:0] imm,

    // rs1
    //output reg rs1_re,
    output reg [31:0] rs1_data,
    // rs2
    //output reg rs2_re,
    output reg [31:0] rs2_data,
    // rd
    output reg rd_we,
    output reg [4:0] rd_addr
);
    always @(posedge clk) begin
        if(rst)begin
            //op_sel <= 4'b0;
            opcode <= 7'b0;
            funct7 <= 7'b0;
            funct3 <= 3'b0;
            imm <= 32'b0;
            rs1_data <= 32'b0;
            rs2_data <= 32'b0;
            rd_addr <= 5'b0;
            rd_we <= 1'b0 ;
        end 
        else if (flush)
        begin
            opcode <= OP_I_IMM;
            funct7 <= 7'b0 ;
            funct3 <= `F3_ADD ;
            imm <= 32'b0 ;
            rs1_data <= 32'b0;
            rs2_data <= 32'b0;
            rd_addr <= 5'b0 ;
            rd_we <= 1'b0 ;
        end
        else
        begin
            //op_sel <= op_sel_i;
            opcode <= opcode_i;
            funct7 <= funct7_i;
            funct3 <= funct3_i;
            imm <= imm_i;
            rs1_data <= rs1_data_i;
            rs2_data <= rs2_data_i;
            rd_addr <= rd_addr_i;
            rd_we <= rd_we_i ;
        end
    end

endmodule