//Danton Klein
//This file contains the registers used to facilitate the 5 stage pipeline.

module IF_ID_Register #(
    parameter int WIDTH = 32
)
(
    input logic[WIDTH-1:0] IF_Pc,
    input logic[31:0] IF_Instruction,

    input logic clk,
    input logic reset,
    input logic stall,
    input logic flush,

    output logic[WIDTH-1:0] ID_Pc,
    output logic[31:0] ID_Instruction
);

    always_ff @(posedge clk or posedge reset) begin
        if(reset) begin
            ID_Pc <= '0;
            ID_Instruction <= '0;
        end
        else if (flush) begin
            ID_Pc <= IF_Pc;
            ID_Instruction <= '0;
        end
        else if (!stall) begin
            ID_Pc <= IF_Pc;
            ID_Instruction <= IF_Instruction;
        end
    end

endmodule

module ID_EX_Register #(
    parameter int WIDTH = 32
)
(
    input logic[WIDTH-1:0] ID_Pc,
    input logic[WIDTH-1:0] ID_RegisterData1,
    input logic[WIDTH-1:0] ID_RegisterData2,
    input logic[WIDTH-1:0] ID_ImmediateGen,
    input logic[6:0] ID_Funct7,
    input logic[2:0] ID_Funct3,
    input logic[4:0] ID_Rs1,
    input logic[4:0] ID_Rs2,
    input logic[4:0] ID_Rd,

    input logic ID_RegWrite,
    input logic ID_MemToReg,
    input logic ID_MemRead,
    input logic ID_MemWrite,
    input logic[2:0] ID_ALUOp,
    input logic ID_Immediate,
    input logic ID_Jump,
    input logic ID_Auipc,

    input logic clk,
    input logic reset,
    input logic flush,

    output logic[WIDTH-1:0] EX_Pc,
    output logic[WIDTH-1:0] EX_RegisterData1,
    output logic[WIDTH-1:0] EX_RegisterData2,
    output logic[WIDTH-1:0] EX_ImmediateGen,
    output logic[6:0] EX_Funct7,
    output logic[2:0] EX_Funct3,
    output logic[4:0] EX_Rs1,
    output logic[4:0] EX_Rs2,
    output logic[4:0] EX_Rd,

    output logic EX_RegWrite,
    output logic EX_MemToReg,
    output logic EX_MemRead,
    output logic EX_MemWrite,
    output logic[2:0] EX_ALUOp,
    output logic EX_Immediate,
    output logic EX_Jump,
    output logic EX_Auipc

);
    always_ff @(posedge clk or posedge reset) begin
        if(reset) begin
            EX_Pc <= '0;
            EX_RegisterData1 <= '0;
            EX_RegisterData2 <= '0;
            EX_ImmediateGen <= '0;
            EX_Funct7 <= '0;
            EX_Funct3 <= '0;
            EX_Rs1 <= '0;
            EX_Rs2 <= '0;
            EX_Rd <= '0;

            EX_RegWrite <= '0;
            EX_MemToReg <= '0;
            EX_MemWrite <= '0;
            EX_MemRead <= '0;
            EX_Immediate <= '0;
            EX_ALUOp <= '0;
            EX_Jump <= '0;
            EX_Auipc <= '0;
        end
        else if(flush) begin
            EX_Pc <= '0;
            EX_RegisterData1 <= '0;
            EX_RegisterData2 <= '0;
            EX_ImmediateGen <= '0;
            EX_Funct7 <= '0;
            EX_Funct3 <= '0;
            EX_Rs1 <= '0;
            EX_Rs2 <= '0;
            EX_Rd <= '0;

            EX_RegWrite <= '0;
            EX_MemToReg <= '0;
            EX_MemWrite <= '0;
            EX_MemRead <= '0;
            EX_Immediate <= '0;
            EX_ALUOp <= '0;
            EX_Jump <= '0;
            EX_Auipc <= '0;
        end
        else begin
            EX_Pc <= ID_Pc;
            EX_RegisterData1 <= ID_RegisterData1;
            EX_RegisterData2 <= ID_RegisterData2;
            EX_ImmediateGen <= ID_ImmediateGen;
            EX_Funct7 <= ID_Funct7;
            EX_Funct3 <= ID_Funct3;
            EX_Rs1 <= ID_Rs1;
            EX_Rs2 <= ID_Rs2;
            EX_Rd <= ID_Rd;

            EX_RegWrite <= ID_RegWrite;
            EX_MemToReg <= ID_MemToReg;
            EX_MemWrite <= ID_MemWrite;
            EX_MemRead <= ID_MemRead;
            EX_Immediate <= ID_Immediate;
            EX_ALUOp <= ID_ALUOp;
            EX_Jump <= ID_Jump;
            EX_Auipc <= ID_Auipc;
        end
    end
endmodule

module EX_MEM_Register #(
    parameter int WIDTH = 32
)
(
    input logic[WIDTH-1:0] EX_Alu,
    input logic[WIDTH-1:0] EX_RegisterData2,
    input logic[4:0] EX_Rs2,
    input logic[2:0] EX_Funct3,
    input logic[4:0] EX_Rd,

    input logic EX_RegWrite,
    input logic EX_MemToReg,
    input logic EX_MemRead,
    input logic EX_MemWrite,

    input logic clk,
    input logic reset,
    input logic flush,

    output logic[WIDTH-1:0] MEM_Alu,
    output logic[WIDTH-1:0] MEM_RegisterData2,
    output logic[4:0] MEM_Rs2,
    output logic[2:0] MEM_Funct3,
    output logic[4:0] MEM_Rd,

    output logic MEM_RegWrite,
    output logic MEM_MemToReg,
    output logic MEM_MemRead,
    output logic MEM_MemWrite
);

    always_ff @(posedge clk or posedge reset) begin
        if(reset) begin
            MEM_Alu <= '0;
            MEM_RegisterData2 <= '0;
            MEM_Rs2 <= '0;
            MEM_Funct3 <= '0;
            MEM_Rd <= '0;

            MEM_RegWrite <= '0;
            MEM_MemToReg <= '0;
            MEM_MemWrite <= '0;
            MEM_MemRead <= '0;
        end
        else if(flush) begin
            MEM_Alu <= '0;
            MEM_RegisterData2 <= '0;
            MEM_Rs2 <= '0;
            MEM_Funct3 <= '0;
            MEM_Rd <= '0;

            MEM_RegWrite <= '0;
            MEM_MemToReg <= '0;
            MEM_MemWrite <= '0;
            MEM_MemRead <= '0;
        end
        else begin
            MEM_Alu <= EX_Alu;
            MEM_RegisterData2 <= EX_RegisterData2;
            MEM_Rs2 <= EX_Rs2;
            MEM_Funct3 <= EX_Funct3;
            MEM_Rd <= EX_Rd;

            MEM_RegWrite <= EX_RegWrite;
            MEM_MemToReg <= EX_MemToReg;
            MEM_MemWrite <= EX_MemWrite;
            MEM_MemRead <= EX_MemRead;
        end
    end
endmodule

module MEM_WB_Register #(
    parameter int WIDTH = 32
)
(
    input logic[WIDTH-1:0] MEM_Data,
    input logic[WIDTH-1:0] MEM_Alu,

    input logic[2:0] MEM_Funct3,
    input logic[4:0] MEM_Rd,

    input logic MEM_RegWrite,
    input logic MEM_MemToReg,

    input logic clk,
    input logic reset,
    input logic flush,

    output logic[WIDTH-1:0] WB_Data,
    output logic[WIDTH-1:0] WB_Alu,

    output logic[4:0] WB_Funct3,
    output logic[4:0] WB_Rd,

    output logic WB_RegWrite,
    output logic WB_MemToReg
);
always_ff @(posedge clk or posedge reset) begin
        if(reset) begin
            WB_Data <= '0;
            WB_Alu <= '0;
            WB_Funct3 <= '0;
            WB_Rd <= '0;
            WB_RegWrite <= '0;
            WB_MemToReg <= '0;
        end
        else if(flush) begin
            WB_Data <= '0;
            WB_Alu <= '0;
            WB_Funct3 <= '0;
            WB_Rd <= '0;
            WB_RegWrite <= '0;
            WB_MemToReg <= '0;
        end
        else begin
            WB_Data <= MEM_Data;
            WB_Alu <= MEM_Alu;
            WB_Funct3 <= MEM_Funct3;
            WB_Rd <= MEM_Rd;
            WB_RegWrite <= MEM_RegWrite;
            WB_MemToReg <= MEM_MemToReg;
        end
    end
endmodule