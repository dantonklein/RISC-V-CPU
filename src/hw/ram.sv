module ram #(
    //Byte-Addresed
    parameter int DATA_WIDTH = 8,
    parameter int ADDR_WIDTH = 32
) (
    input logic clk,

    input logic[ADDR_WIDTH-1:0] address,
    input logic[31:0] data_in,
    input logic[1:0] write, 
    input logic[1:0] read,

    output logic[31:0] data_out
);
    localparam logic[1:0] Store_Byte = 2'd1;
    localparam logic[1:0] Store_HalfWord = 2'd2;
    localparam logic[1:0] Store_Word = 2'd3;

    localparam logic[1:0] Load_Byte = 3'd1;
    localparam logic[1:0] Load_HalfWord = 3'd2;
    localparam logic[1:0] Load_Word = 3'd3;

  	logic [DATA_WIDTH-1:0] mem[2 ** ADDR_WIDTH];

    //Writing Block
    always_ff @(posedge clk) begin
        case(write) 
            //SB
            Store_Byte: mem[address] <= data_in[7:0];

            //SH
            Store_HalfWord: begin
                if(address == (2 ** ADDR_WIDTH - 1)) mem[address] <= data_in[7:0];
                else {mem[address + 1], mem[address]} <= data_in[15:0];
            end

            //SW
            Store_Word: begin
                if(address == (2 ** ADDR_WIDTH - 1)) mem[address] <= data_in[7:0];
                else if(address == (2 ** ADDR_WIDTH - 2)) {mem[address + 1], mem[address]} <= data_in[15:0];
                else if(address == (2 ** ADDR_WIDTH - 3)) {mem[address + 2], mem[address + 1], mem[address]} <= data_in[23:0];
                else {mem[address + 3], mem[address + 2], mem[address + 1], mem[address]} <= data_in;
            end
        endcase

    end

    //Reading Block, this will be fed into the Memory/Write-Back pipeline register so it will be registered later.
    //The logic for handling sign extension for unsigned vs signed loading half words and bytes will be 
    //in the write-back stage to balance responsibilities more amongst the pipeline stages

    logic [23:0] zero_padding;
    always_comb begin
        zero_padding = '0;
        case(read) 
            //LB
            Load_Byte: data_out = {zero_padding, mem[address]};
            //LH
            Load_HalfWord: begin
                if(address == (2 ** ADDR_WIDTH - 1)) data_out = {zero_padding, mem[address]};
                else data_out = {zero_padding[15:0], mem[address + 1], mem[address]};
            end
            //LW
            Load_Word: begin
                if(address == (2 ** ADDR_WIDTH - 1)) data_out = {zero_padding, mem[address]};
                else if(address == (2 ** ADDR_WIDTH - 2)) data_out = {zero_padding[15:0], mem[address + 1], mem[address]};
                else if(address == (2 ** ADDR_WIDTH - 3)) data_out = {zero_padding[7:0], mem[address + 2], mem[address + 1], mem[address]};
                else data_out = {mem[address + 3], mem[address + 2], mem[address + 1], mem[address]};
            end
            default: data_out = '0;
        endcase
    end
endmodule