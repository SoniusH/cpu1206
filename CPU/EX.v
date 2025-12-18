`timescale 1ns/1ps
`include "defines.vh"
module EX(
    input wire rst,

    input wire [`PC_WIDTH-1:0] pc_i, // temporily 10-bit in width,
                            // may change later
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
    output wire rd_we,
    output wire [4:0] rd_addr,
    output reg [31:0] rd_data,

    output reg use_mult, // whether this instruction uses the multiplier
    output reg [1:0] mult_type // multiplier type
);
    assign rd_we = rd_we_i;
    assign rd_addr = rd_addr_i;

    // we assume that all instructions obey the format,
    // therefore in OP_I_IMM and OP_R the funct7 can only have 2 possible values: 
    // 7'b0100000, 7'b0000000.
    // thus we can simplify 1 level of 'case'.
    always (*)begin 
        use_mult = 1'b0;
        mult_type = 2'b00;
        case(opcode_i)
            `OP_U_LUI: begin
                rd_data = imm_i; //lui
            end
            `OP_U_AUIPC: begin
                rd_data = {{(32-`PC_WIDTH){1'b0}},pc}+imm_i; //auipc
            end
            `OP_I_IMM: begin case(funct3_i)
                `F3_ADD: rd_data = rs1_data_i + imm_i; //addi
                `F3_SLL: rd_data = rs1_data_i << imm_i[4:0]; //slli
                `F3_SLT: rd_data = ($signed(rs1_data_i) < $signed(imm_i))? 1 : 0; //slti
                `F3_SLTU: rd_data = (rs1_data_i < imm_i)? 1 : 0; //sltiu
                `F3_XOR: rd_data = rs1_data_i ^ imm_i; //xori
                `F3_SR: begin//srli or srai
                    if(funct7_i[5])begin
                        rd_data = rs1_data_i >>> imm_i[4:0]//srai
                    end else begin
                        rd_data = rs1_data_i >> imm_i[4:0]//srli
                    end
                    /*
                    case(funct7_i)
                        7'b0100000: rd_data = rs1_data_i >>> imm_i[4:0]//srai
                        7'b0000000: rd_data = rs1_data_i >> imm_i[4:0]//srli
                        default:
                    endcase
                    */
                end
                `F3_OR: rd_data = rs1_data_i | imm_i; //ori
                `F3_AND: rd_data = rs1_data_i & imm_i; //andi
            endcase end
            `OP_R: begin 
                if(funct7_i[0]) begin case(funct3_i) //RV32M
                    `F3_MUL: begin
                        use_mult = 1'b1;
                        mult_type = `MULT_TYPE_LOW32;
                    end//rd_data = (rs1_data_i * rs2_data_i)[31:0]; //mul
                    `F3_MULH: begin
                        use_mult = 1'b1;
                        mult_type = `MULT_TYPE_SxS_HIGH32;
                    end //rd_data = ($signed(rs1_data_i) * $signed(rs2_data_i))[63:32]; //mulh
                    `F3_MULHSU: begin
                        use_mult = 1'b1;
                        mult_type = `MULT_TYPE_SxU_HIGH32;
                    end//rd_data = ($signed(rs1_data_i) * rs2_data_i)[63:32]; //mulhsu
                    `F3_MULHU: begin
                        use_mult = 1'b1;
                        mult_type = `MULT_TYPE_UxU_HIGH32;
                    end //rd_data = (rs1_data_i * rs2_data_i)[63:32]; //mulhu
                    `F3_DIV: rd_data = ($signed(rs1_data_i) / $signed(rs2_data_i)); //div
                    `F3_DIVU: rd_data = (rs1_data_i / rs2_data_i); //divu
                    `F3_REM: rd_data = ($signed(rs1_data_i) % $signed(rs2_data_i)); //rem
                    `F3_REMU: rd_data = (rs1_data_i % rs2_data_i); //remu
                endcase end else begin case(funct3_i) //RV32I
                    `F3_ADD: begin //add or sub
                        if(funct7_i[5])begin
                            rd_data = rs1_data_i - rs2_data_i; //sub
                        end else begin
                            rd_data = rs1_data_i + rs2_data_i; //add
                        end
                        /*
                        case(funct7_i)
                            7'b0100000:rd_data = rs1_data_i - rs2_data_i; //sub
                            7'b0000000:rd_data = rs1_data_i + rs2_data_i; //add
                            default:
                        endcase
                        */
                    end
                    `F3_SLL: rd_data = rs1_data_i << rs2_data_i[4:0]; //sll
                    `F3_SLT: rd_data = ($signed(rs1_data_i) < $signed(rs2_data_i))? 1 : 0; //slt
                    `F3_SLTU: rd_data = (rs1_data_i < rs2_data_i)? 1 : 0; //sltu
                    `F3_XOR: rd_data = rs1_data_i ^ rs2_data_i; //xor
                    `F3_SR: begin//srl or sra
                        if(funct7_i[5])begin
                            rd_data = rs1_data_i >>> rs2_data_i[4:0]//sra
                        end else begin
                            rd_data = rs1_data_i >> rs2_data_i[4:0]//srl
                        end
                        /*
                        case(funct7_i)
                            7'b0100000: rd_data = rs1_data_i >>> rs2_data_i[4:0]//sra
                            7'b0000000: rd_data = rs1_data_i >> rs2_data_i[4:0]//srl
                            default:
                        endcase
                        */
                    end
                    `F3_OR: rd_data = rs1_data_i | rs2_data_i; //or
                    `F3_AND: rd_data = rs1_data_i & rs2_data_i; //and
                endcase end
            end
            default:
                rd_data = 32'b0;
        endcase
    end
endmodule