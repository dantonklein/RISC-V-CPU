//Danton Klein
//This file contains the registers used to facilitate the 5 stage pipeline.

module if_id_register #(
    parameter int WIDTH = 32
)
(
    input logic[WIDTH-1:0] pc_out,
    input logic[31:0] instruction_memory_out,

    input logic clk,
    input logic reset,
    input logic enable,

    output logic[WIDTH-1:0] pc_id,
    output logic[31:0] instruction_id
);

    always_ff @(posedge clk or posedge reset) begin
        if(reset) begin
            pc_id <= '0;
            instruction_id <= '0;
        end
        else if (enable) begin
            pc_id <= pc_out;
            instruction_id <= instruction_memory_out;
        end
    end

endmodule

module id_ex_register #(
    parameter int WIDTH = 32
)
(
    input logic[WIDTH-1:0] pc_id,
    input logic[WIDTH-1:0] rs1_id,
    input logic[WIDTH-1:0] rs2_id,
    input logic[WIDTH-1:0] imm_gen_out,
    input logic[6:0] funct7_id,
    input logic[2:0] funct3_id,
    input logic[4:0] rd_id,

    input logic RegWrite_id,
    input logic MemtoReg_id,
    input logic AttemptBranch_id,
    input logic MemWrite_id,
    input logic MemRead_id,
    input logic ALUSrc_id,
    input logic[3:0] ALUOp_id,
    //JAL, JALR
    //Type of Load

    input logic clk,
    input logic reset,
    input logic enable,

    output logic[WIDTH-1:0] pc_ex,
    output logic[WIDTH-1:0] rs1_ex,
    output logic[WIDTH-1:0] rs2_ex,
    output logic[WIDTH-1:0] imm_gen_ex,
    output logic[6:0] funct7_ex,
    output logic[2:0] funct3_ex,
    output logic[4:0] rd_ex,

    output logic RegWrite_ex,
    output logic MemtoReg_ex,
    output logic AttemptBranch_ex,
    output logic MemWrite_ex,
    output logic MemRead_ex,
    output logic ALUSrc_ex,
    output logic[3:0] ALUOp_ex

);
    always_ff @(posedge clk or posedge reset) begin
        if(reset) begin
            pc_ex <= '0;
            rs1_ex <= '0;
            rs2_ex <= '0;
            imm_gen_ex <= '0;
            funct7_ex <= '0;
            funct3_ex <= '0;
            rd_ex <= '0;
            RegWrite_ex <= '0;
            MemtoReg_ex <= '0;
            AttemptBranch_ex <= '0;
            MemWrite_ex <= '0;
            MemRead_ex <= '0;
            ALUSrc_ex <= '0;
            ALUOp_ex <= '0;
        end
        else if (enable) begin
            pc_ex <= pc_id;
            rs1_ex <= rs1_id;
            rs2_ex <= rs2_id;
            imm_gen_ex <= imm_gen_out;
            funct7_ex <= funct7_id;
            funct3_ex <= funct3_id;
            rd_ex <= rd_id;
            RegWrite_ex <= RegWrite_id;
            MemtoReg_ex <= MemtoReg_id;
            AttemptBranch_ex <= AttemptBranch_id;
            MemWrite_ex <= MemWrite_id;
            MemRead_ex <= MemRead_id;
            ALUSrc_ex <= ALUSrc_id;
            ALUOp_ex <= ALUOp_id;
        end
    end
endmodule

module ex_mem_register #(
    parameter int WIDTH = 32
)
(
    input logic[WIDTH-1:0] pc_adder_out,
    input logic[WIDTH-1:0] alu_out,
    input logic[WIDTH-1:0] rs2_ex,
    input logic[4:0] rd_ex,

    input logic RegWrite_ex,
    input logic MemtoReg_ex,
    input logic AttemptBranch_ex,
    input logic MemWrite_ex,
    input logic MemRead_ex,
    input logic alu_zero,

    input logic clk,
    input logic reset,
    input logic enable,

    output logic[WIDTH-1:0] pc_adder_mem,
    output logic[WIDTH-1:0] alu_mem,
    output logic[WIDTH-1:0] rs2_mem,
    output logic[4:0] rd_mem,

    output logic RegWrite_mem,
    output logic MemtoReg_mem,
    output logic AttemptBranch_mem,
    output logic MemWrite_mem,
    output logic MemRead_mem,
    output logic alu_zero_mem

);

    always_ff @(posedge clk or posedge reset) begin
        if(reset) begin
            pc_adder_mem <= '0;
            alu_mem <= '0;
            rs2_mem <= '0;
            rd_mem <= '0;
            RegWrite_mem <= '0;
            MemtoReg_mem <= '0;
            AttemptBranch_mem <= '0;
            MemWrite_mem <= '0;
            MemRead_mem <= '0;
            alu_zero_mem <= '0;
        end
        else if(enable) begin
            pc_adder_mem <= pc_adder_out;
            alu_mem <= alu_out;
            rs2_mem <= rs2_ex;
            rd_mem <= rd_ex;
            RegWrite_mem <= RegWrite_ex;
            MemtoReg_mem <= MemtoReg_ex;
            AttemptBranch_mem <= AttemptBranch_ex;
            MemWrite_mem <= MemWrite_ex;
            MemRead_mem <= MemRead_ex;
            alu_zero_mem <= alu_zero;
        end
    end
endmodule

module mem_wb_register #(
    parameter int WIDTH = 32
)
(
    input logic[WIDTH-1:0] data_mem_read_out,
    input logic[WIDTH-1:0] alu_mem,
    input logic[4:0] rd_mem,

    input logic RegWrite_mem,
    input logic MemtoReg_mem,

    input logic clk,
    input logic reset,
    input logic enable,

    output logic[WIDTH-1:0] data_mem_read_out_wb,
    output logic[WIDTH-1:0] alu_wb,
    output logic[4:0] rd_wb,

    output logic RegWrite_wb,
    output logic MemtoReg_wb
);
always_ff @(posedge clk or posedge reset) begin
        if(reset) begin
            data_mem_read_out_wb <= '0;
            alu_wb <= '0;
            rd_wb <= '0;
            RegWrite_wb <= '0;
            MemtoReg_wb <= '0;
        end
        else if(enable) begin
            data_mem_read_out_wb <= data_mem_read_out;
            alu_wb <= alu_mem;
            rd_wb <= rd_mem;
            RegWrite_wb <= RegWrite_mem;
            MemtoReg_wb <= MemtoReg_mem;
        end
    end
endmodule