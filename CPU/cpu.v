`timescale 1ns/1ps
`include "defines.vh"
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
    wire [`PC_WIDTH-1:0] pc, pc_delayed;
    wire [`PC_WIDTH-1:0] pc_id_i;
    wire [`PC_WIDTH-1:0] pc_id_o, pc_ex_i;
    // for instructions
    wire [31:0] inst_if_o, inst_id_i;
    // opcode, funct7, funct3
    // all signals that go between levels need 2 wires for reg
    wire [6:0] opcode_id_o, opcode_ex_i;
    wire [6:0] funct7_id_o, funct7_ex_i;
    wire [2:0] funct3_id_o, funct3_ex_i;
    // imm, rs1_data, rs2_data
    wire [31:0] imm_id_o, imm_ex_i,
                rs1_data_id_i, rs1_data_id_o, rs1_data_ex_i,
                rs2_data_id_i, rs2_data_id_o, rs2_data_ex_i;
    // rd_addr
    wire [4:0]  rd_addr_id_o, rd_addr_ex_i,
                rd_addr_ex_o, rd_addr_mem_i, 
                rd_addr_mem_o, rd_addr_wb_i;
    // rd_we
    wire rd_we_id_o, rd_we_ex_i,
         rd_we_ex_o, rd_we_mem_i,
         rd_we_mem_o, rd_we_wb_i;

    // rd_data
    wire [31:0] rd_data_ex_o, rd_data_mem_i,
                rd_data_mem_o, rd_data_wb_i;

    // for mult_manager
    wire use_mult_ex_o;
    wire [1:0] mult_type_ex_o;
    wire [4:0] rd_addrs_mult_o [`MULT_PPL_STAGE-1:0];
    wire [31:0] rd_data_mult_o;
    wire [`MULT_PPL_STAGE-1:0] mult_uses_o;
    // The 32 Data Registers
    reg32x32 data_reg(.clk(clk),.rst(rst),
                      .we(data_reg_we),.waddr(data_reg_waddr),.wdata(data_reg_wdata),
                      .re1(data_reg_re1),.raddr1(data_reg_raddr1),.rdata1(data_reg_rdata1),
                      .re2(data_reg_re2),.raddr2(data_reg_raddr2),.rdata2(data_reg_rdata2));

    // Instruction Registers
    // re temporily set to 1'b1
    // may be changed to BRAM later
    inst_mem u_inst_mem(.clk(clk),
                      .re(1'b1),.raddr(pc),.rdata(inst));

    // 5-levels and inter-level regs
    //IF u_if();
    pc_gen u_pc_gen(.clk(clk), .rst(rst), .pc(pc));
    pc_delay u_pc_delay(.clk(clk),.rst(rst),.pc_i(pc),.pc_o(pc_delayed));
    IF_ID u_if_id(.clk(clk),.rst(rst),
                  .if_pc(pc_delayed),.if_inst(inst),
                  .id_pc(pc_id_i),.id_inst(inst_id_i));

    ID u_id(.rst(rst),.inst(inst), .pc_i(pc_id_i), .pc(pc_id_o),
            .opcode(opcode_id_o),.funct7(funct7_id_o),.funct3(funct3_id_o), .imm(imm_id_o),
            .rs1_re(data_reg_re1), .rs1_addr(data_reg_raddr1), .rs1_data_i(rs1_data_id_i),.rs1_data(rs1_data_id_o),
            .rs2_re(data_reg_re2), .rs2_addr(data_reg_raddr2), .rs2_data_i(rs1_data_id_i),.rs2_data(rs2_data_id_o),
            .rd_we(rd_we_id_o), .rd_addr(rd_addr_id_o));
    // rs1 and rs2 data is selected in fw4RAW_reg
    // to solve RAW data hazard in reg case
    fw4RAW_reg u_fw4RAW_reg(.rst(rst),
                .rs1_re_id_i(data_reg_re1), .rs1_addr_id_i(data_reg_raddr1), rs1_data_from_reg_i(data_reg_rdata1),
                .rs2_re_id_i(data_reg_re2), .rs2_addr_id_i(data_reg_raddr2), rs2_data_from_reg_i(data_reg_rdata2),
                .rd_we_ex_i(rd_we_ex_i), .rd_addr_ex_i(rd_addr_ex_i), .rd_data_ex_i(rd_data_ex_o),
                .rd_we_mem_i(rd_we_mem_i), .rd_addr_mem_i(rd_addr_mem_i), .rd_data_mem_i(rd_data_mem_i),
                .rd_we_wb_i(rd_we_wb_i), .rd_addr_wb_i(rd_addr_wb_i), .rd_data_wb_i(rd_data_wb_i),
                .rs1_data_id(rs1_data_id_i), .rs2_data_id(rs2_data_id_i)
                );

    ID_EX u_id_ex(.clk(clk),.rst(rst), .pc_i(pc_id_o), .pc(pc_ex_i),
                  .opcode_i(opcode_id_o),.funct3_i(funct3_id_o),.funct7_i(funct7_id_o),
                  .imm_i(imm_id_o),.rs1_data_i(rs1_data_id_o),.rs2_data_i(rs2_data_id_o),
                  .rd_we_i(rd_we_id_o), .rd_addr_i(rd_addr_id_o),
                  .opcode(opcode_ex_i),.funct3(funct3_ex_i),.funct7(funct7_ex_i),
                  .imm(imm_ex_i), .rs1_data(rs1_data_ex_i), .rs2_data(rs2_data_ex_i),
                  .rd_we(rd_we_ex_i), .rd_addr(rd_addr_ex_i));
    
    EX u_ex(.rst(rst), .pc_i(pc_ex_i),
            .opcode_i(opcode_ex_i), .funct7_i(funct7_ex_i), .funct3_i(funct3_ex_i),
            .imm_i(imm_ex_i), .rs1_data_i(rs1_data_ex_i),.rs2_data_i(rs2_data_ex_i),
            .rd_we_i(rd_we_ex_i), .rd_addr_i(rd_addr_ex_i),
            .rd_we(rd_we_ex_o), .rd_addr(rd_addr_ex_o), .rd_data(rd_data_ex_o),
            .use_mult(use_mult_ex_o), .mult_type(mult_type_ex_o)
            );
    mult_manager u_mult_manager(.clk(clk),.rst(rst),
                .A(rs1_data_ex_i),.B(rs2_data_ex_i),
                .use_i(use_mult_ex_o),.mult_type_i(mult_type_ex_o),.rd_addr_i(rd_addr_ex_i),
                .rd_addrs(rd_addrs_mult_o),.mult_uses(mult_uses_o),.rd_data(rd_data_mult_o));
                
    stall_ctrl_mult u_stall_ctrl_mult(
                .clk(clk), .rst(rst),
                .rd_addrs_mult_i(rd_addrs_mult_o),.mult_uses_i(mult_uses_o),
                .rs1_re_id_i(data_reg_re1),.rs1_addr_id_i(data_reg_raddr1),
                .rs2_re_id_i(data_reg_re2),.rs2_addr_id_i(data_reg_raddr2),
                .rd_we_id_i(rd_we_id_o),.rd_addr_id_i(rd_addr_id_o),
                // outputs to stall ctrl
                .stall_req_o()
                );
    EX_MEM u_ex_mem(.clk(clk),.rst(rst),
                    .rd_we_i(rd_we_ex_o), .rd_addr_i(rd_addr_ex_o),.rd_data_i(rd_data_ex_o)
                    .rd_we(rd_we_mem_i), .rd_addr(rd_addr_mem_i), .rd_data(rd_data_mem_i));
    
    MEM u_mem(.rst(rst),
              .rd_we_i(rd_we_mem_i), .rd_addr_i(rd_addr_mem_i),.rd_data_i(rd_data_mem_i)
              .rd_we(rd_we_mem_o), .rd_addr(rd_addr_mem_o), .rd_data(rd_data_mem_o));

    MEM_WB u_mem_wb(.clk(clk),.rst(rst),
                   .rd_we_i(rd_we_mem_o), .rd_addr_i(rd_addr_mem_o),.rd_data_i(rd_data_mem_o)
                   .rd_we(rd_we_wb_i), .rd_addr(rd_addr_wb_i), .rd_data(rd_data_wb_i));

    WB u_wb(.rst(rst),
            .rd_we_i(rd_we_wb_i), .rd_addr_i(rd_addr_wb_i),.rd_data_i(rd_data_wb_i)
            .rd_we(data_reg_we), .rd_addr(data_reg_waddr), .rd_data(data_reg_wdata));

endmodule