`timescale 1ns/1ps
`include "defines.vh"
module ID(
    //input wire clk,
    input wire rst,

    input wire [31:0] id_inst, //id_instruction

    output wire [6:0] opcode,
    output wire [6:0] funct7,
    output wire [2:0] funct3,

    //output wire [2:0] type, // 6 types
    output wire [31:0] imm,
    // rs1
    output wire rs1_re,
    output wire [5:0] rs1_addr,
    input wire [31:0] rs1_data_i,
    output wire [31:0] rs1_data,
    // rs2
    output wire rs2_re,
    output wire [5:0] rs2_addr,
    input wire [31:0] rs2_data_i,
    output wire [31:0] rs2_data,
    // rd
    output wire rd_we,
    output wire [4:0] rd_addr
    
);
    localparam TYPE_R = 3'd0,
               TYPE_I = 3'd1,
               TYPE_S = 3'd2,
               TYPE_B = 3'd3,
               TYPE_U = 3'd4,
               TYPE_J = 3'd5;
    wire [6:0] opcode;

    assign opcode = id_inst[6:0];
    assign rs1_addr = {5{rs1_re}}&id_inst[24:20];//rs1_re ? id_inst[24:20] : 5'b0;
    assign rs2_addr = {5{rs2_re}}&id_inst[19:15];//rs2_re ? id_inst[19:15] : 5'b0;
    assign rd_addr = {5{rd_we}}&id_inst[11:7];//rd_we ? id_inst[11:7] : 5'b0;
    assign rs1_data = rs1_data_i;
    assign rs2_data = rs2_data_i;

    // re1,re2,we,imm,op_sel
    always @(*) begin
        //op_sel = 4'b0;
        rs1_re = 1'b0;
        rs2_re = 1'b0;
        rd_we = 1'b0;
        imm = 32'b0;
        case(opcode)
            OP_U_LUI:begin
                imm = {id_inst[31:12], 12'b0};
                rd_we = 1'b1;
            end//U lui
            OP_U_AUIPC:begin
                imm = {id_inst[31:12], 12'b0};
                rd_we = 1'b1;
            end//U auipc
            OP_J_JAL:begin

            end//J jal
            OP_J_JALR:begin

            end//J jalr
            OP_B:begin

            end//B beq,bne,blt,bge,bltu,bgeu
            OP_I_LOAD:begin
                rs1_re = 1'b1;
                rd_we = 1'b1;
                imm = {20'b0,inst[31:20]};
            end//I lb,lh,lw,lhu,lwu
            OP_S:begin

            end//S sb,sh,sw
            OP_I_IMM:begin
                rs1_re = 1'b1;
                rd_we = 1'b1;
                if(funct3==3'b001 || funct3==3'b101)begin
                    imm = 32'b0;
                end else begin
                    imm = {20'b0,inst[31:20]};
                end
            end//I addi,ori,xori,andi,slti,sltiu,slli,srli,srai
            OP_R:begin
                rs1_re = 1'b1;
                rs2_re  1'b1;
                rd_we = 1'b1;
            end//R
            OP_I_FENCE:begin

            end//I fence,fence.i
            OP_I_CSR:begin

            end//I ...
            default:begin

            end
        endcase
    end
    
endmodule