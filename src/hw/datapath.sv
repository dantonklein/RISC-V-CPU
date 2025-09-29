//This is the datapath that connects all the parts of the CPU.
//My naming convention is that all caps is a module while first letter caps is for signals.

module datapath #(
    parameter int ADDR_WIDTH = 16
) (
    input logic debug_enable,
    input logic clk,
    input logic rst,
    input logic instruction_write,
    input logic[31:0] instruction_in,
    output logic data_access_fault_exception
);
logic [31:0] four;
logic on;
logic off;
logic [9:0] ten_bit_zero;

assign four = 32'd4;
assign on = 1;
assign off = 0;
assign ten_bit_zero = 0;

//Intermediary Signals

//Instruction Fetch Stage
logic IF_Mispredict;
logic IF_Not_Stall;
logic IF_Stall;

logic[1:0] IF_Pc_Mux_Select;


logic[31:0] IF_Pc_Adder;
logic[31:0] IF_Pc_Mux;
logic[31:0] IF_Pc;
logic[31:0] IF_Instruction;

//ID Stage
logic ID_Stall;
logic ID_Flush;
logic ID_Jump;
logic ID_Mispredict;
logic ID_PredictBranchTaken;
logic ID_AttemptBranch;
logic ID_IsJALR;
logic ID_BranchTaken;

logic ID_Jump_Pre_Mux;
logic ID_RegWrite_Pre_Mux;
logic ID_MemToReg_Pre_Mux;
logic ID_MemRead_Pre_Mux;
logic ID_MemWrite_Pre_Mux;
logic[2:0] ID_ALUOp_Pre_Mux;
logic ID_Immediate_Pre_Mux;
logic ID_Auipc_Pre_Mux;
logic[9:0] ID_Packaged_Mux_Input;
logic ID_Stall_Mux_Select;
logic[9:0] ID_Packaged_Mux_Output;

logic ID_RegWrite;
logic ID_MemToReg;
logic ID_MemRead;
logic ID_MemWrite;
logic[2:0] ID_ALUOp;
logic ID_Immediate;
logic ID_Auipc;

logic ID_Branch_Alu;

logic[31:0] ID_Branch_Target_Adder;
logic[31:0] ID_Pc_Plus_Four_Adder;
logic[31:0] ID_Corrected_Pc_Mux;
logic[31:0] ID_Corrected_Pc_Register;
logic[31:0] ID_Jump_Adder;
logic[31:0] ID_Pc;
logic[31:0] ID_Instruction;
logic[31:0] ID_Read_Data_1;
logic[31:0] ID_Read_Data_2;
logic[31:0] ID_Immediate_Generator;
logic[31:0] ID_Jump_Adder_Mux;

logic[31:0] ID_Branch_Alu_Forward_Mux1;
logic[31:0] ID_Branch_Alu_Forward_Mux2;

logic[1:0] ID_Branch_Alu_Forward_Mux_Select_1;
logic[1:0] ID_Branch_Alu_Forward_Mux_Select_2;

logic[2:0] ID_Pc_Slice;
logic[4:0] ID_Rs1;
logic[4:0] ID_Rs2;
logic[4:0] ID_Rd;
logic[2:0] ID_Funct3;
logic[6:0] ID_Funct7;

//Execution Stage
logic EX_RegWrite;
logic EX_MemToReg;
logic EX_MemRead;
logic EX_MemWrite;
logic[2:0] EX_ALUOp;
logic EX_Immediate;
logic EX_Jump;
logic EX_Auipc;

logic[1:0] EX_Alu_Forward_Mux_Select_1;
logic[1:0] EX_Alu_Forward_Mux_Select_2;

logic[31:0] EX_Alu_Forward_Mux1;
logic[31:0] EX_Alu_Forward_Mux2;

logic[3:0] EX_Alu_Select;

logic EX_Alu_Input1_Mux_Select;

logic[31:0] EX_Alu_Input1_Mux;
logic[31:0] EX_Alu_Input2_Mux;

logic[31:0] EX_Alu;

logic[31:0] EX_Pc;
logic[31:0] EX_Read_Data1;
logic[31:0] EX_Read_Data2;
logic[31:0] EX_Immediate_Generator;
logic[6:0] EX_Funct7;
logic[2:0] EX_Funct3;
logic[4:0] EX_Rs1;
logic[4:0] EX_Rs2;
logic[4:0] EX_Rd;

//Data Memory Stage
logic MEM_RegWrite;
logic MEM_MemToReg;
logic MEM_MemRead;
logic MEM_MemWrite;

logic[31:0] MEM_Alu_Result;
logic[31:0] MEM_Read_Data2;

logic[31:0] MEM_Data_Mux;
logic[31:0] MEM_Data_Ram;

logic MEM_Data_Mux_Select;

logic[4:0] MEM_Rs2;
logic[2:0] MEM_Funct3;
logic[4:0] MEM_Rd;

//Write Back Stage
logic WB_RegWrite;
logic WB_MemToReg;

logic[31:0] WB_MemOrReg_Mux;
logic[31:0] WB_Sign_Extender;
logic[31:0] WB_Data;
logic[31:0] WB_Alu;

logic[2:0] WB_Funct3;
logic[4:0] WB_Rd;
//Instantiated Modules

//Instruction Fetch Stage

mux_controller IF_PC_MUX_CONTROLLER (
    .ID_PredictBranchTaken(ID_PredictBranchTaken),
    .IF_Mispredict(IF_Mispredict),
    .ID_Jump(ID_Jump),
    .MUX_Select(IF_Pc_Mux_Select)
);


mux4x1 #(
    .WIDTH(32)
) IF_PC_MUX (
    .in0(IF_Pc_Adder),
    .in1(ID_Branch_Target_Adder),
    .in2(ID_Corrected_Pc_Register),
    .in3(ID_Jump_Adder),
    .select(IF_Pc_Mux_Select),
    .data_out(IF_Pc_Mux)
);

assign IF_Stall = !debug_enable || ID_Stall;
assign IF_Not_Stall = !IF_Stall; 

register #(
    .WIDTH(32)
) IF_PC (
    .in(IF_Pc_Mux),
    .clk(clk),
    .reset(rst),
    .enable(IF_Not_Stall),
    .data_out(IF_Pc)
);

adder #(
    .WIDTH(32)
) IF_PC_ADDER (
    .in0(IF_Pc),
    .in1(four),
    .out(IF_Pc_Adder)
);

register #(
    .WIDTH(1)
) IF_MISPREDICT_DELAY (
    .in(ID_Mispredict),
    .clk(clk),
    .reset(rst),
    .enable(on),
    .data_out(IF_Mispredict)
);

instruction_ram #(
    .DATA_WIDTH(32),
    //.ADDR_WIDTH(32)
    .ADDR_WIDTH(32),
    .RAM_SIZE_WIDTH(ADDR_WIDTH)
) IF_INSTRUCTION_RAM (
    .clk(clk),
    .instruction_write(instruction_write),
    .instruction_in(instruction_in),
    .PC15_2(IF_Pc[15:2]),
    .flush(ID_Flush),
    .instruction(IF_Instruction)
);

//Instruction Decode Stage

IF_ID_Register #(
    .WIDTH(32)
) IF_ID_REGISTER (
    .IF_Pc(IF_Pc),
    .IF_Instruction(IF_Instruction),
    .clk(clk),
    .reset(rst),
    .stall(IF_Stall),
    .flush(ID_Flush),
    .ID_Pc(ID_Pc),
    .ID_Instruction(ID_Instruction)
);

assign ID_Funct7 = ID_Instruction[31:25];
assign ID_Rs2 = ID_Instruction[24:20];
assign ID_Rs1 = ID_Instruction[19:15];
assign ID_Funct3 = ID_Instruction[14:12];
assign ID_Rd = ID_Instruction[11:7];

control ID_CONTROL_UNIT (
    .instruction(ID_Instruction[6:0]),
    .AttemptBranch(ID_AttemptBranch),
    .IsJALR(ID_IsJALR),
    .Jump(ID_Jump_Pre_Mux),
    .RegWrite(ID_RegWrite_Pre_Mux),
    .MemToReg(ID_MemToReg_Pre_Mux),
    .MemRead(ID_MemRead_Pre_Mux),
    .MemWrite(ID_MemWrite_Pre_Mux),
    .ALUOp(ID_ALUOp_Pre_Mux),
    .Immediate(ID_Immediate_Pre_Mux),
    .Auipc(ID_Auipc_Pre_Mux)
);

assign ID_Stall_Mux_Select = ID_Stall | ID_Flush;

assign ID_Packaged_Mux_Input = 
{ID_Jump_Pre_Mux,ID_RegWrite_Pre_Mux,ID_MemToReg_Pre_Mux,ID_MemRead_Pre_Mux,
ID_MemWrite_Pre_Mux,ID_ALUOp_Pre_Mux,ID_Immediate_Pre_Mux,ID_Auipc_Pre_Mux};

assign {ID_Jump,ID_RegWrite,ID_MemToReg,ID_MemRead,ID_MemWrite,ID_ALUOp,
ID_Immediate,ID_Auipc} = ID_Packaged_Mux_Output;

mux2x1 #(
    .WIDTH(10)
) ID_STALL_MUX (
    .in0(ID_Packaged_Mux_Input),
    .in1(ten_bit_zero),
    .select(ID_Stall_Mux_Select),
    .data_out(ID_Packaged_Mux_Output)
);

hazard_unit ID_HAZARD_DETECTION_UNIT (
    .ID_AttemptBranch(ID_AttemptBranch),
    .ID_BranchTaken(ID_BranchTaken),
    .ID_PredictBranchTaken(ID_PredictBranchTaken),
    .ID_IsJALR(ID_IsJALR),
    .EX_RegWrite(EX_RegWrite),
    .EX_MemRead(EX_MemRead),
    .EX_Rd(EX_Rd),
    .ID_Rs1(ID_Rs1),
    .ID_Rs2(ID_Rs2),
    .flush(ID_Flush),
    .mispredict(ID_Mispredict),
    .ID_Stall(ID_Stall),
    .clk(clk),
    .rst(rst)
);

adder #(
    .WIDTH(32)
) ID_PC_PLUS_FOUR_ADDER (
    .in0(ID_Pc),
    .in1(four),
    .out(ID_Pc_Plus_Four_Adder)
);

registerfile #(
    .DATA_WIDTH(32),
    .NUM_REGISTERS(32)
) ID_REGISTERFILE (
    .clk(clk),
    .write(WB_RegWrite),
    .reg_rd0(ID_Rs1),
    .reg_rd1(ID_Rs2),
    .reg_wr(WB_Rd),
    .data_in(WB_MemOrReg_Mux),
    .data_out0(ID_Read_Data_1),
    .data_out1(ID_Read_Data_2)
);

immgen #(
    .DATA_WIDTH(32)
) ID_IMMEDIATE_GENERATOR (
    .inst(ID_Instruction),
    .extended_immediate(ID_Immediate_Generator)
);

adder #(
    .WIDTH(32)
) ID_BRANCH_TARGET_ADDER (
    .in0(ID_Pc),
    .in1(ID_Immediate_Generator),
    .out(ID_Branch_Target_Adder)
);

mux2x1 #(
    .WIDTH(32)
) ID_CORRECTED_PC_MUX (
    .in0(ID_Branch_Target_Adder),
    .in1(ID_Pc_Plus_Four_Adder),
    .select(ID_PredictBranchTaken),
    .data_out(ID_Corrected_Pc_Mux)
);

register #(
    .WIDTH(32)
) ID_CORRECTED_PC_REGISTER(
    .in(ID_Corrected_Pc_Mux),
    .clk(clk),
    .reset(rst),
    .enable(on),
    .data_out(ID_Corrected_Pc_Register)
);

assign ID_Pc_Slice = ID_Pc[4:2];

branch_prediction #(
    .table_width(3)
) ID_BRANCH_PREDICTION_UNIT (
    .ID_PC_Slice(ID_Pc_Slice),
    .ID_BranchTaken(ID_BranchTaken),
    .ID_AttemptBranch(ID_AttemptBranch),
    .clk(clk),
    .rst(rst),
    .ID_PredictBranchTaken(ID_PredictBranchTaken)
);

assign ID_BranchTaken = ID_AttemptBranch & ID_Branch_Alu;

mux2x1 #(
    .WIDTH(32)
) ID_JUMP_ADDER_MUX (
    .in0(ID_Pc),
    .in1(ID_Branch_Alu_Forward_Mux1),
    .select(ID_IsJALR),
    .data_out(ID_Jump_Adder_Mux)
);

adder #(
    .WIDTH(32)
) ID_JUMP_ADDER (
    .in0(ID_Jump_Adder_Mux),
    .in1(ID_Immediate_Generator),
    .out(ID_Jump_Adder)
);

branch_alu_forwarding_unit ID_BRANCH_ALU_FORWARDING_UNIT_1 (
    .MEM_RegWrite(MEM_RegWrite),
    .WB_RegWrite(WB_RegWrite),
    .ID_Rs(ID_Rs1),
    .MEM_Rd(MEM_Rd),
    .WB_Rd(WB_Rd),
    .forward_data(ID_Branch_Alu_Forward_Mux_Select_1)
);

branch_alu_forwarding_unit ID_BRANCH_ALU_FORWARDING_UNIT_2 (
    .MEM_RegWrite(MEM_RegWrite),
    .WB_RegWrite(WB_RegWrite),
    .ID_Rs(ID_Rs2),
    .MEM_Rd(MEM_Rd),
    .WB_Rd(WB_Rd),
    .forward_data(ID_Branch_Alu_Forward_Mux_Select_2)
);

mux3x1 #(
    .WIDTH(32)
) ID_BRANCH_ALU_FORWARD_MUX1 (
    .in0(ID_Read_Data_1),
    .in1(MEM_Alu_Result),
    .in2(WB_MemOrReg_Mux),
    .select(ID_Branch_Alu_Forward_Mux_Select_1),
    .data_out(ID_Branch_Alu_Forward_Mux1)
);

mux3x1 #(
    .WIDTH(32)
) ID_BRANCH_ALU_FORWARD_MUX2 (
    .in0(ID_Read_Data_2),
    .in1(MEM_Alu_Result),
    .in2(WB_MemOrReg_Mux),
    .select(ID_Branch_Alu_Forward_Mux_Select_2),
    .data_out(ID_Branch_Alu_Forward_Mux2)
);

branch_alu #(
    .DATA_WIDTH(32)
) ID_BRANCH_ALU (
    .input0(ID_Branch_Alu_Forward_Mux1),
    .input1(ID_Branch_Alu_Forward_Mux2),
    .funct3(ID_Funct3),
    .out(ID_Branch_Alu)
);

ID_EX_Register #(
    .WIDTH(32)
) ID_EX_REGISTER (
    .ID_Pc(ID_Pc),
    .ID_RegisterData1(ID_Read_Data_1),
    .ID_RegisterData2(ID_Read_Data_2),
    .ID_ImmediateGen(ID_Immediate_Generator),
    .ID_Funct7(ID_Funct7),
    .ID_Funct3(ID_Funct3),
    .ID_Rs1(ID_Rs1),
    .ID_Rs2(ID_Rs2),
    .ID_Rd(ID_Rd),

    .ID_RegWrite(ID_RegWrite),
    .ID_MemToReg(ID_MemToReg),
    .ID_MemRead(ID_MemRead),
    .ID_MemWrite(ID_MemWrite),
    .ID_ALUOp(ID_ALUOp),
    .ID_Immediate(ID_Immediate),
    .ID_Jump(ID_Jump),
    .ID_Auipc(ID_Auipc),

    .clk(clk),
    .reset(rst),
    //.flush(ID_Flush),

    .EX_Pc(EX_Pc),
    .EX_RegisterData1(EX_Read_Data1),
    .EX_RegisterData2(EX_Read_Data2),
    .EX_ImmediateGen(EX_Immediate_Generator),
    .EX_Funct7(EX_Funct7),
    .EX_Funct3(EX_Funct3),
    .EX_Rs1(EX_Rs1),
    .EX_Rs2(EX_Rs2),
    .EX_Rd(EX_Rd),

    .EX_RegWrite(EX_RegWrite),
    .EX_MemToReg(EX_MemToReg),
    .EX_MemRead(EX_MemRead),
    .EX_MemWrite(EX_MemWrite),
    .EX_ALUOp(EX_ALUOp),
    .EX_Immediate(EX_Immediate),
    .EX_Jump(EX_Jump),
    .EX_Auipc(EX_Auipc)
);

//Execution Stage

alu_data_forwarding_unit EX_ALU_DATA_FORWARDING_UNIT1 (
    .MEM_RegWrite(MEM_RegWrite),
    .WB_RegWrite(WB_RegWrite),
    .EX_Rs(EX_Rs1),
    .MEM_Rd(MEM_Rd),
    .WB_Rd(WB_Rd),
    .forward_data(EX_Alu_Forward_Mux_Select_1)
);

alu_data_forwarding_unit EX_ALU_DATA_FORWARDING_UNIT2 (
    .MEM_RegWrite(MEM_RegWrite),
    .WB_RegWrite(WB_RegWrite),
    .EX_Rs(EX_Rs2),
    .MEM_Rd(MEM_Rd),
    .WB_Rd(WB_Rd),
    .forward_data(EX_Alu_Forward_Mux_Select_2)
);

alucontroller EX_ALU_CONTROLLER (
    .ALUOp(EX_ALUOp),
    .Funct7(EX_Funct7),
    .Funct3(EX_Funct3),
    .aluselect(EX_Alu_Select)
);

assign EX_Alu_Input1_Mux_Select = EX_Auipc | EX_Jump;

mux2x1 #(
    .WIDTH(32)
) EX_ALU_INPUT1_MUX (
    .in0(EX_Alu_Forward_Mux1),
    .in1(EX_Pc),
    .select(EX_Alu_Input1_Mux_Select),
    .data_out(EX_Alu_Input1_Mux)
);

mux2x1 #(
    .WIDTH(32)
) EX_ALU_INPUT2_MUX (
    .in0(EX_Alu_Forward_Mux2),
    .in1(EX_Immediate_Generator),
    .select(EX_Immediate),
    .data_out(EX_Alu_Input2_Mux)
);

mux3x1 #(
    .WIDTH(32)
) EX_ALU_FORWARD_MUX1 (
    .in0(EX_Read_Data1),
    .in1(MEM_Alu_Result),
    .in2(WB_MemOrReg_Mux),
    .select(EX_Alu_Forward_Mux_Select_1),
    .data_out(EX_Alu_Forward_Mux1)
);

mux3x1 #(
    .WIDTH(32)
) EX_ALU_FORWARD_MUX2 (
    .in0(EX_Read_Data2),
    .in1(MEM_Alu_Result),
    .in2(WB_MemOrReg_Mux),
    .select(EX_Alu_Forward_Mux_Select_2),
    .data_out(EX_Alu_Forward_Mux2)
);


alu #(
    .DATA_WIDTH(32)
) EX_ALU(
    .input0(EX_Alu_Input1_Mux),
    .input1(EX_Alu_Input2_Mux),
    .aluselect(EX_Alu_Select),
    .out(EX_Alu)
);

EX_MEM_Register #(
    .WIDTH(32)
) EX_MEM_REGISTER (
    .EX_Alu(EX_Alu),
    .EX_RegisterData2(EX_Alu_Forward_Mux2),
    .EX_Rs2(EX_Rs2),
    .EX_Funct3(EX_Funct3),
    .EX_Rd(EX_Rd),

    .EX_RegWrite(EX_RegWrite),
    .EX_MemToReg(EX_MemToReg),
    .EX_MemRead(EX_MemRead),
    .EX_MemWrite(EX_MemWrite),

    .clk(clk),
    .reset(rst),
    .flush(off),

    .MEM_Alu(MEM_Alu_Result),
    .MEM_RegisterData2(MEM_Read_Data2),
    .MEM_Rs2(MEM_Rs2),
    .MEM_Funct3(MEM_Funct3),
    .MEM_Rd(MEM_Rd),

    .MEM_RegWrite(MEM_RegWrite),
    .MEM_MemToReg(MEM_MemToReg),
    .MEM_MemRead(MEM_MemRead),
    .MEM_MemWrite(MEM_MemWrite)
);
//Data Memory Stage
memory_data_forwarding_unit MEM_MEMORY_DATA_FORWARDING_UNIT (
    .WB_RegWrite(WB_RegWrite),
    .MEM_Rs2(MEM_Rs2),
    .WB_Rd(WB_Rd),
    .forward_data(MEM_Data_Mux_Select)
);

mux2x1 #(
    .WIDTH(32)
) MEM_DATA_MUX (
    .in0(MEM_Read_Data2),
    .in1(WB_MemOrReg_Mux),
    .select(MEM_Data_Mux_Select),
    .data_out(MEM_Data_Mux)
);

data_ram #(
    .DATA_WIDTH(8),
    .ADDR_WIDTH(32),
    .RAM_SIZE_WIDTH(ADDR_WIDTH)
) MEM_DATA_RAM (
    .clk(clk),

    .address(MEM_Alu_Result),
    .data_in(MEM_Data_Mux),
    .write(MEM_MemWrite),
    .read(MEM_MemRead),
    .funct3(MEM_Funct3),
    .data_out(MEM_Data_Ram),
    .data_access_fault_exception(data_access_fault_exception)
);

MEM_WB_Register #(
    .WIDTH(32)
) MEM_WB_REGISTER (
    .MEM_Data(MEM_Data_Ram),
    .MEM_Alu(MEM_Alu_Result),
    .MEM_Funct3(MEM_Funct3),
    .MEM_Rd(MEM_Rd),
    .MEM_RegWrite(MEM_RegWrite),
    .MEM_MemToReg(MEM_MemToReg),

    .clk(clk),
    .reset(rst),

    .WB_Data(WB_Data),
    .WB_Alu(WB_Alu),
    .WB_Funct3(WB_Funct3),
    .WB_Rd(WB_Rd),

    .WB_RegWrite(WB_RegWrite),
    .WB_MemToReg(WB_MemToReg)
);
//Write Back Stage
loads_sign_extend #(
    .DATA_WIDTH(32)
) WB_SIGN_EXTENDER (
    .in(WB_Data),
    .funct3(WB_Funct3),
    .out(WB_Sign_Extender)
);

mux2x1 #(
    .WIDTH(32)
) WB_MEMORREG_MUX (
    .in0(WB_Alu),
    .in1(WB_Sign_Extender),
    .select(WB_MemToReg),
    .data_out(WB_MemOrReg_Mux)
);


endmodule