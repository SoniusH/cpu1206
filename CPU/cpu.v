`timescale 1ns/1ps
module cpu(
    input wire clk,
    input wire rst,
    input wire [31:0] inst
);
    // wires
    // for data regs
    wire data_reg_we, data_reg_re1, data_reg_re2;
    wire [4:0] data_reg_waddr, data_reg_raddr1, data_reg_raddr2;
    wire [31:0] data_reg_wdata, data_reg_rdata1, data_reg_rdata2;
    // for pc regs
    wire pc;
    wire [31:0] inst_if_id_i, inst_if_id_o;
    // opcode, funct7, funct3
    // all signals that go between levels need 2 wires for reg
    wire [6:0] opcode_id_ex_i, opcode_id_ex_o;
    wire [6:0] funct7_id_ex_i, funct7_id_ex_o;
    wire [2:0] funct3_id_ex_i, funct3_id_ex_o;
    // imm, rs1_data, rs2_data
    wire [31:0] imm_id_ex_i, imm_id_ex_o,
                rs1_data_id_ex_i, rs1_data_id_ex_o,
                rs2_data_id_ex_i, rs2_data_id_ex_o;
    // rd_addr
    wire [4:0]  rd_addr_id_ex_i, rd_addr_id_ex_o,
                rd_addr_ex_mem_i, rd_addr_ex_mem_o, 
                rd_addr_mem_wb_i, rd_addr_mem_wb_o;
    // rd_we
    wire rd_we_id_ex_i, rd_we_id_ex_o,
         rd_we_ex_mem_i, rd_we_ex_mem_o,
         rd_we_mem_wb_i, rd_we_mem_wb_o;

    // rd_data
    wire [31:0] rd_data_ex_mem_i, rd_data_ex_mem_o,
                rd_data_mem_wb_i, rd_data_mem_wb_o;
    // The 32 Data Registers
    reg32x32 u_data_reg(.clk(clk),.rst(rst),
                        .we(data_reg_we),.waddr(data_reg_waddr),.wdata(data_reg_wdata),
                        .re1(data_reg_re1),.raddr1(data_reg_raddr1),.rdata1(data_reg_rdata1),
                        .re2(data_reg_re2),.raddr2(data_reg_raddr2),.rdata2(data_reg_rdata2));
    // Instruction Registers
    reg [31:0] inst_reg [255:0];

    // 5-levels and inter-level regs
    IF u_if();

    IF_ID u_if_id();

    ID u_id(.rst(rst),.id_inst(inst),.opcode(opcode_id_ex_i),.funct7(funct7_id_ex_i),.funct3(funct3_id_ex_i), .imm(imm_id_ex_i),
            .rs1_re(data_reg_re1), .rs1_addr(data_reg_raddr1), .rs1_data_i(data_reg_rdata1),.rs1_data(rs1_data_id_ex_i),
            .rs2_re(data_reg_re2), .rs2_addr(data_reg_raddr2), .rs2_data_i(data_reg_rdata2),.rs2_data(rs2_data_id_ex_i),
            .rd_we(rd_we_id_ex_i), .rd_addr(rd_addr_id_ex_i));

    ID_EX u_id_ex(.clk(clk),.rst(rst),.opcode_i(opcode_id_ex_i),.funct3_i(funct3_id_ex_i),.funct7_i(funct7_id_ex_i),
                  .imm_i(imm_id_ex_i),rs1_data_i(rs1_data_id_ex_i),.rs2_data_i(rs2_data_id_ex_i),
                  .rd_we_i(rd_we_id_ex_i), .rd_addr_i(rd_addr_id_ex_i),
                  .opcode(opcode_id_ex_o),.funct3(funct3_id_ex_o),.funct7(funct7_id_ex_o),
                  .imm(imm_id_ex_o), .rs1_data(rs1_data_id_ex_o), .rs2_data(rs2_data_id_ex_o),
                  .rd_we(rd_we_id_ex_o), .rd_addr(rd_addr_id_ex_o));
    
    EX u_ex(.rst(rst), opcode_i(opcode_id_ex_o), funct7_i(funct7_id_ex_o), funct3_i(funct3_id_ex_o),
            .imm_i(imm_id_ex_o), .rs1_data_i(rs1_data_id_ex_o),.rs2_data_i(rs2_data_id_ex_o),
            .rd_we_i(rd_we_id_ex_o), .rd_addr_i(rd_addr_id_ex_o),
            .rd_we(rd_we_ex_mem_i), .rd_addr(rd_addr_ex_mem_i), .rd_data(rd_data_ex_mem_i));
    
    EX_ME u_ex_mem(.clk(clk),.rst(rst),
                   .rd_we_i(rd_we_ex_mem_i), .rd_addr_i(rd_addr_ex_mem_i),.rd_data_i(rd_data_ex_mem_i)
                   .rd_we(rd_we_ex_mem_o), .rd_addr(rd_addr_ex_mem_o), .rd_data(rd_data_ex_mem_o));
    
    ME u_mem(.rst(rst),
             .rd_we_i(rd_we_ex_mem_o), .rd_addr_i(rd_addr_ex_mem_o),.rd_data_i(rd_data_ex_mem_o)
             .rd_we(rd_we_mem_wb_i), .rd_addr(rd_addr_mem_wb_i), .rd_data(rd_data_mem_wb_i));

    ME_WB u_mem_wb(.clk(clk),.rst(rst),
                   .rd_we_i(rd_we_mem_wb_i), .rd_addr_i(rd_addr_mem_wb_i),.rd_data_i(rd_data_mem_wb_i)
                   .rd_we(rd_we_mem_wb_o), .rd_addr(rd_addr_mem_wb_o), .rd_data(rd_data_mem_wb_o));

    WB u_wb(.rst(rst),
            .rd_we_i(rd_we_mem_wb_o), .rd_addr_i(rd_addr_mem_wb_o),.rd_data_i(rd_data_mem_wb_o)
            .rd_we(data_reg_we), .rd_addr(data_reg_waddr), .rd_data(data_reg_wdata));

    // inter-level regs

    


endmodule