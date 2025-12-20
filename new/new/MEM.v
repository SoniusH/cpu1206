`define OP_I_LOAD 7'b0000011
`define OP_S 7'b0100011
module MEM (
    input wire rst,

    input wire rd_we_i,
    input wire [4:0] rd_addr_i,
    input wire [31:0] rd_data_i,

    output reg rd_we,
    output reg [4:0] rd_addr,
    output reg [31:0] rd_data,

    input wire [6:0] aluop_i,
    input wire [2:0] funct3,
    
    input wire ram_busy,
    input wire ram_done,

    input wire [31:0] s_data_i,       //data need to be stored
    input wire [31:0] ram_addr_i,
    input wire [31:0] ram_data_i,    // data read from ram

    output reg [31:0] ram_addr_o,
    output reg ram_we_o,
    output reg [31:0] ram_data_o,

    output reg [3:0] ram_byte_sel_o,
    
    output reg ram_ce,

    output reg stall_req_o
    );
    always @(*) begin
        if (rst == 1) begin
            rd_we <= 0;
            rd_addr <= 5'b0;
            rd_data <= 32'b0;
            ram_addr_o <= 32'b0;
            ram_we_o <= 0;
            ram_data_o <= 32'b0;
            ram_byte_sel_o <= 4'b0;
            ram_ce <= 0;
            stall_req_o <= 0;
        end else if ((aluop_i != `OP_I_LOAD) & (aluop_i != `OP_S)) begin
            rd_we <= rd_we_i;
            rd_addr <= rd_addr_i;
            rd_data <= rd_data_i;
            ram_addr_o <= 32'b0;
            ram_we_o <= 0;
            ram_data_o <= 32'b0;
            ram_byte_sel_o <= 4'b0;
            ram_ce <= 0;
            stall_req_o <= 0;
            end else if (ram_done) begin
                stall_req_o <= 0;
                case (aluop_i)
                    //load instrument
                    `OP_I_LOAD : begin
                        case (funct3)
                        //instrument lw
                        3'b010 : begin
                            rd_we <= rd_we_i;
                            rd_addr <= rd_addr_i;
                            rd_data <= ram_data_i;
                            ram_addr_o <= ram_addr_i;
                            ram_we_o <= 0;
                            ram_data_o <= 32'b0;
                            ram_byte_sel_o <= 4'b1111;
                            ram_ce <= 1;
                        end
                        //instrument lbu
                        3'b100 : begin
                            rd_we <= rd_we_i;
                            rd_addr <= rd_addr_i;
                            ram_addr_o <= ram_addr_i;
                            ram_we_o <= 0;
                            ram_data_o <= 32'b0;
                            ram_ce <= 1;
                            //byte selection
                            case (ram_addr_i[1:0])
                                2'b00 : begin
                                    rd_data <= {24'b0,ram_data_i[7:0]};
                                    ram_byte_sel_o <= 4'b0001;
                                end
                                2'b01 : begin
                                    rd_data <= {24'b0,ram_data_i[15:8]};
                                    ram_byte_sel_o <= 4'b0010;
                                end
                                2'b10 : begin
                                    rd_data <= {24'b0,ram_data_i[23:16]};
                                    ram_byte_sel_o <= 4'b0100;
                                end
                                2'b11 : begin
                                    rd_data <= {24'b0,ram_data_i[31:24]};
                                    ram_byte_sel_o <= 4'b1000;
                                end
                            endcase
                        end
                        //instrument lb
                        3'b000 : begin
                            rd_we <= rd_we_i;
                            rd_addr <= rd_addr_i;
                            ram_addr_o <= ram_addr_i;
                            ram_we_o <= 0;
                            ram_data_o <= 32'b0;
                            ram_ce <= 1;
                            //byte selection
                            case (ram_addr_i[1:0])
                                2'b00 : begin
                                    rd_data <= {{24{ram_data_i[7]}},ram_data_i[7:0]};
                                    ram_byte_sel_o <= 4'b0001;
                                end
                                2'b01 : begin
                                    rd_data <= {{24{ram_data_i[15]}},ram_data_i[15:8]};
                                    ram_byte_sel_o <= 4'b0010;
                                end
                                2'b10 : begin
                                    rd_data <= {{24{ram_data_i[23]}},ram_data_i[23:16]};
                                    ram_byte_sel_o <= 4'b0100;
                                end
                                2'b11 : begin
                                    rd_data <= {{24{ram_data_i[31]}},ram_data_i[31:24]};
                                    ram_byte_sel_o <= 4'b1000;
                                end
                            endcase
                        end
                        //instrument lhu
                        3'b101 : begin
                            rd_we <= rd_we_i;
                            rd_addr <= rd_addr_i;
                            ram_addr_o <= ram_addr_i;
                            ram_we_o <= 0;
                            ram_data_o <= 32'b0;
                            ram_ce <= 1;
                            //byte selection
                            case (ram_addr_i[1:0])
                                2'b00 : begin
                                    rd_data <= {16'b0,ram_data_i[15:0]};
                                    ram_byte_sel_o <= 4'b0011;
                                end
                                2'b10 : begin
                                    rd_data <= {16'b0,ram_data_i[31:16]};
                                    ram_byte_sel_o <= 4'b1100;
                                end
                                default : begin
                                    rd_data <= 32'b0;
                                    ram_byte_sel_o <= 4'b0000;
                                end
                            endcase
                        end
                        //instrument lh
                        3'b001 : begin
                            rd_we <= rd_we_i;
                            rd_addr <= rd_addr_i;
                            ram_addr_o <= ram_addr_i;
                            ram_we_o <= 0;
                            ram_data_o <= 32'b0;
                            ram_ce <= 1;
                            //byte selection
                            case (ram_addr_i[1:0])
                                2'b00 : begin
                                    rd_data <= {{16{ram_data_i[15]}},ram_data_i[15:0]};
                                    ram_byte_sel_o <= 4'b0011;
                                end
                                2'b10 : begin
                                    rd_data <= {{16{ram_data_i[31]}},ram_data_i[31:16]};
                                    ram_byte_sel_o <= 4'b1100;
                                end
                                default : begin
                                    rd_data <= 32'b0;
                                    ram_byte_sel_o <= 4'b0000;
                                end
                            endcase
                        end
                        default : begin
                            rd_we <= 0;
                            rd_addr <= 5'b0;
                            rd_data <= 32'b0;
                            ram_addr_o <= 32'b0;
                            ram_we_o <= 0;
                            ram_data_o <= 32'b0;
                            ram_byte_sel_o <= 4'b0;
                            ram_ce <= 0;
                        end
                        endcase
                    end
                    default : begin
                        rd_we <= rd_we_i;
                        rd_addr <= rd_addr_i;
                        rd_data <= rd_data_i;
                        ram_addr_o <= 32'b0;
                        ram_we_o <= 0;
                        ram_data_o <= 32'b0;
                        ram_byte_sel_o <= 4'b0;
                        ram_ce <= 0;
                    end
                endcase
            end else if (!ram_busy) begin
                case (aluop_i)
                        `OP_I_LOAD : begin
                            stall_req_o <= 1;
                            ram_addr_o <= {ram_addr_i[31:2],2'b00};
                            ram_ce <= 1;
                            ram_we_o <= 0;
                            ram_data_o <= 32'b0;
                        end
                         //store instrument
                        `OP_S : begin
                            stall_req_o <= 1;
                            case (funct3) 
                                //instrument sw
                                3'b010 : begin
                                    rd_we <= rd_we_i;
                                    rd_addr <= rd_addr_i;
                                    rd_data <= rd_data_i;
                                    ram_addr_o <= ram_addr_i;
                                    ram_we_o <= 1;
                                    ram_data_o <= s_data_i;
                                    ram_byte_sel_o <= 4'b1111;
                                    ram_ce <= 1;
                                end
                                //instrument sb
                                3'b000 : begin
                                    rd_we <= rd_we_i;
                                    rd_addr <= rd_addr_i;
                                    rd_data <= rd_data_i;
                                    ram_addr_o <= ram_addr_i;
                                    ram_we_o <= 1;
                                    ram_data_o <= {s_data_i[7:0],s_data_i[7:0],s_data_i[7:0],s_data_i[7:0]};
                                    ram_ce <= 1;
                                    case (ram_addr_i[1:0])
                                        2'b00 : begin
                                            ram_byte_sel_o <= 4'b0001;
                                        end
                                        2'b01 : begin
                                            ram_byte_sel_o <= 4'b0010;
                                        end
                                        2'b10 : begin
                                            ram_byte_sel_o <= 4'b0100;
                                        end
                                        2'b11 : begin
                                            ram_byte_sel_o <= 4'b1000;
                                        end
                                    endcase
                                end
                                //instrument sh
                                3'b001 : begin
                                    rd_we <= rd_we_i;
                                    rd_addr <= rd_addr_i;
                                    rd_data <= rd_data_i;
                                    ram_addr_o <= ram_addr_i;
                                    ram_we_o <= 1;
                                    ram_data_o <= {s_data_i[15:0],s_data_i[15:0]};
                                    ram_ce <= 1;
                                    case (ram_addr_i[1:0])
                                        2'b00 : begin
                                            ram_byte_sel_o <= 4'b0011;
                                        end
                                        2'b10 : begin
                                            ram_byte_sel_o <= 4'b1100;
                                        end
                                        default : begin
                                            ram_byte_sel_o <= 4'b0000;
                                        end
                                    endcase
                                end
                                default : begin
                                    rd_we <= 0;
                                    rd_addr <= 5'b0;
                                    rd_data <= 32'b0;
                                    ram_addr_o <= 32'b0;
                                    ram_we_o <= 0;
                                    ram_data_o <= 32'b0;
                                    ram_byte_sel_o <= 4'b0;
                                    ram_ce <= 0;
                                end
                            endcase
                         end
                         default : begin
                             rd_we <= rd_we_i;
                             rd_addr <= rd_addr_i;
                             rd_data <= rd_data_i;
                             ram_addr_o <= 32'b0;
                             ram_we_o <= 0;
                             ram_data_o <= 32'b0;
                             ram_byte_sel_o <= 4'b0;
                             ram_ce <= 0;
                         end
                    endcase
            end else begin
                stall_req_o <= 1;
            end
    end
endmodule