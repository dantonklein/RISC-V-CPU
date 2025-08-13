//Module that simulates data memory
module data_ram #(
    //Byte-Addresed
    parameter int DATA_WIDTH = 8,
    parameter int ADDR_WIDTH = 32
) (
    input logic clk,

    input logic[ADDR_WIDTH-1:0] address,
    input logic[31:0] data_in,
    input logic write, 
    input logic read,
    input logic[2:0] funct3,

    output logic[31:0] data_out,
    output logic data_access_fault_exception
);
    localparam logic[1:0] SB = 3'b000;
    localparam logic[1:0] SH = 3'b001;
    localparam logic[1:0] SW = 3'b010;

    localparam logic[1:0] LB = 3'b000;
    localparam logic[1:0] LH = 3'b001;
    localparam logic[1:0] LW = 3'b010;
    localparam logic[1:0] LBU = 3'b100;
    localparam logic[1:0] LHU = 3'b101;
    


  	logic [DATA_WIDTH-1:0] mem[2 ** ADDR_WIDTH];

    //Check for fault exception
    always_comb begin
        data_access_fault_exception = 0;
        if((funct3 == SH && write) || (funct3 == LHU && read) || (funct3 == LH && read)) begin
            if(address == 2 ** (ADDR_WIDTH - 1)) data_access_fault_exception = 1;
        end
        else if((funct3 == SW && write) || (funct3 == LW && read)) begin
            if(address > 2 ** (ADDR_WIDTH - 1) - 3) data_access_fault_exception = 1;
        end
    end

    //Writing Block
    always_ff @(posedge clk) begin
        if(write) begin
            case(funct3) 
                SB: mem[address] <= data_in[7:0];

                SH: if(!data_access_fault_exception) {mem[address + 1], mem[address]} <= data_in[15:0];

                SW: if(!data_access_fault_exception) {mem[address + 3], mem[address + 2], mem[address + 1], mem[address]} <= data_in;
            endcase
        end

    end

    //Reading Block, this will be fed into the Memory/Write-Back pipeline register so it will be registered later.
    //The logic for handling sign extension for unsigned vs signed loading half words and bytes will be 
    //in the write-back stage to balance responsibilities more amongst the pipeline stages

    //I understand that on an FPGA this would absolutely nuke performance but this is simulating an external ram.
    logic [23:0] zero_padding;
    always_comb begin
        zero_padding = '0;
        if(read) begin
            case(funct3) 
                LB: data_out = {zero_padding, mem[address]};

                LBU: data_out = {zero_padding, mem[address]};
                
                LH: if(!data_access_fault_exception) data_out = {zero_padding[15:0], mem[address + 1], mem[address]};

                LHU: if(!data_access_fault_exception) data_out = {zero_padding[15:0], mem[address + 1], mem[address]};

                LW: if(!data_access_fault_exception) data_out = {mem[address + 3], mem[address + 2], mem[address + 1], mem[address]};
            default: data_out = '0;
            endcase
        end
    end
endmodule

//Module that simulates instruction memory
module instruction_ram #(
    //Byte-Addresed
    parameter int DATA_WIDTH = 8,
    parameter int ADDR_WIDTH = 32
) (
    input logic clk,
    input logic instruction_write,
    input logic[31:0] instruction_in,
    input logic[ADDR_WIDTH-1:0] PC,

    output logic[31:0] instruction
);
    logic [DATA_WIDTH-1:0] mem[2 ** ADDR_WIDTH];

    //Writing block (only used for debug)
    always_ff @(posedge clk) begin
        if(instruction_write) {mem[PC + 3], mem[PC + 2], mem[PC + 1], mem[PC]} <= instruction_in;
    end

    //Reading block
    always_comb begin
        instruction = {mem[PC + 3], mem[PC + 2], mem[PC + 1], mem[PC]};
    end
endmodule