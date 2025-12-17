/*********** Some Width for CPU ***********/
`define PC_WIDTH 10
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
/*********** For Multiplications and Multipliers ***********/
`define MULT_PPL_STAGE 5 //multiplier pipeline stages
`define MULT_MODULE_NAME_SxS mult_gen_0 //multiplier module name for signed x signed
`define MULT_MODULE_NAME_SxU mult_gen_1 //multiplier module name for signed x unsigned
`define MULT_MODULE_NAME_UxU mult_gen_2 //multiplier module name for unsigned x unsigned