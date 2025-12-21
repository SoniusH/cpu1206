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

    output wire [6:0] opcode_ex_o,
    output wire rd_we,
    output wire [4:0] rd_addr,
    output reg [31:0] rd_data,

    output reg use_mult, // whether this instruction uses the multiplier
    output reg [1:0] mult_type, // multiplier type

    // ram read and write
    // address and mask are shared, controlled by we and re.
    output reg ram_we,
    output reg ram_re,
    output reg [`MEM_ADDR_WIDTH-1:0] ram_wr_addr,
    output reg [31:0] ram_w_data,
    output reg [3:0] ram_wr_mask,
    output reg ram_r_sign_ext ,//signal extend or not
    //output reg [`MEM_ADDR_WIDTH-1:0] ram_r_addr,
    //output reg [3:0] ram_r_mask

    output reg pc_jump ,
    output reg [`PC_WIDTH-1:0] pc_target
);
    assign rd_we = rd_we_i;
    assign rd_addr = rd_addr_i;
    assign opcode_ex_o = opcode_i ;
    //B-type and J-type 
    reg branch_taken;  // 分支是否跳转
    reg [`PC_WIDTH-1:0] return_addr;

    // 返回地址计算（对于JAL/JALR）
    assign return_addr = pc_i + 32'h4;

    // we assume that all instructions obey the format,
   // // therefore in OP_I_IMM and OP_R the funct7 can only have 2 possible values: 
   // // 7'b0100000, 7'b0000000.
    // thus we can simplify 1 level of 'case'.
    //********************* ALU **********************
    // U_LUI, U_AUIPC, I_IMM, R
    always @(*)begin 
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
                // not RV32M
                if(!funct7_i[0]) begin case(funct3_i) //RV32I
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
            `OP_J_JAL:begin
                rd_data = return_addr
                pc_target = pc_i + imm_i ;
                pc_jump = 1'b1 ;
            end
            `OP_J_JALR:begin
                rd_data = return_addr ;
                pc_target = { (rs1_data_i + imm_i)[31:1], 1'b0 };
                pc_jump = 1'b1;   
            end
            `OP_B:begin
                pc_target = pc_i + imm_i<<1;
                case(funct3_i)
                    `F3_BEQ:  branch_taken = (rs1_data_i == rs2_data_i);      // beq
                    `F3_BNE:  branch_taken = (rs1_data_i != rs2_data_i);      // bne
                    `F3_BLT:  branch_taken = ($signed(rs1_data_i) < $signed(rs2_data_i));  //BLT
                    `F3_BGE:  branch_taken = ($signed(rs1_data_i) >= $signed(rs2_data_i)); // bge
                    `F3_BLTU: branch_taken = (rs1_data_i < rs2_data_i);       // bltu
                    `F3_BGEU: branch_taken = (rs1_data_i >= rs2_data_i);      // bgeu
                    default : branch_taken =  1'b0 ;
                endcase
                pc_jump = branch_taken;
            end
            default:
                rd_data = 32'b0;
        endcase
    end
    //********** Multiplication and Division ***********
    // RV32M
    always @(*)begin 
        use_mult = 1'b0;
        mult_type = 2'b00;
        if(opcode_i == `OP_R && funct7_i[0]) begin case(funct3_i) //RV32M
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
            //`F3_DIV: rd_data = ($signed(rs1_data_i) / $signed(rs2_data_i)); //div
            //`F3_DIVU: rd_data = (rs1_data_i / rs2_data_i); //divu
            //`F3_REM: rd_data = ($signed(rs1_data_i) % $signed(rs2_data_i)); //rem
            //`F3_REMU: rd_data = (rs1_data_i % rs2_data_i); //remu
        endcase end
    end
    //********************* MEM **********************
    // I_LOAD, S
    always @(*)begin 
        ram_we = 1'b0;
        ram_re = 1'b0;
        ram_wr_addr = `MEM_ADDR_WIDTH'b0;
        ram_wr_mask = 4'b0000;
        ram_w_data = 32'b0;
        ram_r_sign_ext = 1'b0;
        case(opcode_i)
            `OP_S: begin 
                ram_we = 1'b1;
                // BRAM addr add 1 is 4 Bytes.
                // Therefore here divided by 4.
                //(rs1_data_i + imm_i)[`MEM_ADDR_WIDTH-1:0] >> 2;
                ram_wr_addr = (rs1_data_i + imm_i)[`MEM_ADDR_WIDTH+1:2];
                case(funct3_i)
                    `F3_SW:begin
                        ram_wr_mask = 4'b1111;
                        // little endian
                        ram_w_data = {rs2_data_i[7:0],rs2_data_i[15:8],rs2_data_i[23:16],rs2_data_i[31:24]};
                    end
                    `F3_SH:begin case((rs1_data_i + imm_i)[1:0])
                        2'b00:begin
                            ram_wr_mask = 4'b1100;
                            ram_w_data = {rs2_data_i[7:0],rs2_data_i[15:8],16'b0};
                        end
                        2'b10:begin
                            ram_wr_mask = 4'b0011;
                            ram_w_data = {16'b0,rs2_data_i[7:0],rs2_data_i[15:8]};
                        end
                        // no need for default. we have set the values at the beginning.
                    endcase end
                    `F3_SB:begin case((rs1_data_i + imm_i)[1:0])
                        2'b00:begin
                            ram_wr_mask = 4'b1000;
                            ram_w_data = {rs2_data_i[7:0],23'b0};
                        end
                        2'b01:begin
                            ram_wr_mask = 4'b0100;
                            ram_w_data = {8'b0,rs2_data_i[7:0],16'b0};
                        end
                        2'b10:begin
                            ram_wr_mask = 4'b0010;
                            ram_w_data = {16'b0,rs2_data_i[7:0],8'b0};
                        end
                        2'b11:begin
                            ram_wr_mask = 4'b0001;
                            ram_w_data = {23'b0,rs2_data_i[7:0]};
                        end
                    endcase end
                    //default:
                endcase
            end
            `OP_I_LOAD: begin 
                ram_re = 1'b1;
                ram_wr_addr = (rs1_data_i + imm_i)[`MEM_ADDR_WIDTH+1:2]
                case(funct3_i)
                    `F3_LW:begin
                        ram_wr_mask = 4'b1111;
                    end
                    `F3_LH:begin 
                        ram_r_sign_ext = 1'b1;
                        case((rs1_data_i + imm_i)[1:0])
                            2'b00:begin
                                ram_wr_mask = 4'b1100;
                            end
                            2'b10:begin
                                ram_wr_mask = 4'b0011;
                            end
                            // no need for default. we have set the values at the beginning.
                        endcase 
                    end
                    `F3_LB:begin 
                        ram_r_sign_ext = 1'b1;
                        case((rs1_data_i + imm_i)[1:0])
                            2'b00:begin
                                ram_wr_mask = 4'b1000;
                            end
                            2'b01:begin
                                ram_wr_mask = 4'b0100;
                            end
                            2'b10:begin
                                ram_wr_mask = 4'b0010;
                            end
                            2'b11:begin
                                ram_wr_mask = 4'b0001;
                            end
                        endcase 
                    end
                    `F3_LHU:begin
                        case((rs1_data_i + imm_i)[1:0])
                            2'b00:begin
                                ram_wr_mask = 4'b1100;
                            end
                            2'b10:begin
                                ram_wr_mask = 4'b0011;
                            end
                            // no need for default. we have set the values at the beginning.
                        endcase 
                    end
                    `F3_LBU: begin
                        case((rs1_data_i + imm_i)[1:0])
                            2'b00:begin
                                ram_wr_mask = 4'b1000;
                            end
                            2'b01:begin
                                ram_wr_mask = 4'b0100;
                            end
                            2'b10:begin
                                ram_wr_mask = 4'b0010;
                            end
                            2'b11:begin
                                ram_wr_mask = 4'b0001;
                            end
                        endcase 
                    end
                endcase
            end
        endcase
    end
endmodule