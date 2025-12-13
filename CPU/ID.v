`timescale 1ns/1ps
`include "defines_op.vh"
module ID(
    //input wire clk,
    input wire rst,
    input wire [15:0] pc_i, // temporily 16-bit in width,
                            // may change later
    input wire [31:0] id_inst, // id_instruction from inst_mem
    output wire [15:0] pc, // to ex
    // Note: in RV32I there are only 11 opcodes,
    // should we use 4 bits only?
    output wire [6:0] opcode, // main operation code
    // sub operation codes cannot be compressed any further as all 3 bits are used.
    output wire [2:0] funct3, // sub operation code
    // Note: as in RV32I funct7 is always 7'b0100000 or 7'b0000000 when used,
    // we can temporarily only put out funct7[5] to distinguish the 2 cases.
    output wire [6:0] funct7, // sub-sub operation code
    

    output wire [31:0] imm, // **put out: immediate value, to ex
    // rs1
    output wire rs1_re, // connected to reg read enable 1
    output wire [5:0] rs1_addr, //connected to reg read address 1
    input wire [31:0] rs1_data_i,// from reg read data 1
    output wire [31:0] rs1_data,// **put out: to ex rs1 data
    // rs2
    output wire rs2_re, // connected to reg read enable 2
    output wire [5:0] rs2_addr,// connected to reg read address 2
    input wire [31:0] rs2_data_i,// from reg read data 2
    output wire [31:0] rs2_data,// **put out: to ex rs2 data
    // rd
    output wire rd_we, // connected forward to WB
    output wire [4:0] rd_addr // connected forward to WB
    
);
    localparam TYPE_R = 3'd0,
               TYPE_I = 3'd1,
               TYPE_S = 3'd2,
               TYPE_B = 3'd3,
               TYPE_U = 3'd4,
               TYPE_J = 3'd5;
    
    // as in EX we have another opcode-decoding process,
    // is it necessary to have funct3_en and funct7_en here?
    // reg funct3_en, funct7_en;

    assign pc = pc_i;
    assign opcode = id_inst[6:0];
    assign funct3 = id_inst[14:12];
    assign funct7 = id_inst[31:25];
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