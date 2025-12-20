/*********** Some Width for CPU ***********/
`define PC_WIDTH 10
`define MEM_ADDR_WIDTH 10
`define DATA_WIDTH 32
`define REG_ADDR_WIDTH 5
/*********** For Opcodes Decoding ***********/
// RV32I
// opcodes
`define OP_R 7'b0110011
`define OP_I_LOAD 7'b0000011
`define OP_I_IMM  7'b0010011
`define OP_I_FENCE 7'b1110011
`define OP_I_CSR 7'b1110011
`define OP_S 7'b0100011
`define OP_B 7'b1100011
`define OP_J_JAL 7'b1101111
`define OP_J_JALR 7'b1100111
`define OP_U_LUI 7'b0110111
`define OP_U_AUIPC 7'b0010111

// funct3 when OP_I_IMM or OP_R
// sub is a kind of add
// sr includes srl and sra.
`define F3_ADD 3'b000
`define F3_SLL 3'b001
`define F3_SR  3'b101
`define F3_XOR 3'b100
`define F3_OR  3'b110
`define F3_AND 3'b111
`define F3_SLT 3'b010
`define F3_SLTU 3'b011
// funct3 when OP_R in RV32M
`define F3_MUL  3'b000
`define F3_MULH 3'b001
`define F3_MULHSU 3'b010
`define F3_MULHU 3'b011
`define F3_DIV  3'b100
`define F3_DIVU 3'b101
`define F3_REM  3'b110
`define F3_REMU 3'b111
// funct3 when OP_I_LOAD or OP_S
`define F3_LB  3'b000
`define F3_LH  3'b001
`define F3_LW  3'b010
`define F3_LBU 3'b100
`define F3_LHU 3'b101
`define F3_SB  3'b000
`define F3_SH  3'b001
`define F3_SW  3'b010
/*********** For Multiplications and Multipliers ***********/
`define MULT_PPL_STAGE 5 //multiplier pipeline stages
`define MULT_MODULE_NAME_SxS mult_gen_0 //multiplier module name for signed x signed
`define MULT_MODULE_NAME_SxU mult_gen_1 //multiplier module name for signed x unsigned
`define MULT_MODULE_NAME_UxU mult_gen_2 //multiplier module name for unsigned x unsigned
`define MULT_MODULE_NAME_33x33 mult_gen_3 //multiplier module name for 33bit, 
                            //which can implement all the 3 kinds of multiplication.
`define MULT_TYPE_LOW32 2'b00 //multiplier type: low 32 bits
`define MULT_TYPE_SxS_HIGH32 2'b01 //multiplier type: signed x signed, high 32 bits
`define MULT_TYPE_SxU_HIGH32 2'b10 //multiplier type: signed x unsigned, high 32 bits
`define MULT_TYPE_UxU_HIGH32 2'b11 //multiplier type: unsigned x unsigned, high 32 bits
/*********** For Divisions and Dividers ***********/
`define DIV_PPL_STAGE 36 //divider pipeline stages
`define DIV_MODULE_NAME div_gen_0 //divider module name
`define DIV_TYPE_SIGNED 1'b1 //divider type: signed
`define DIV_TYPE_UNSIGNED 1'b0 //divider type: unsigned
`define DIV_TYPE_QUOTIENT 1'b0 //divider type: quotient
`define DIV_TYPE_REMAINDER 1'b1 //divider type: remainder