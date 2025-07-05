module ram #(
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 32
) (
    input logic clk, rst,

    input logic[ADDR_WIDTH-1:0] address,
    input logic[DATA_WIDTH-1:0] data_in,
    input logic write, read,

    output logic[DATA_WIDTH-1:0] data_out
);
    logic [DATA_WIDTH-1:0] mem[2**ADDR_WIDTH];

    always_ff @(posedge clk) begin
        if(write) mem[address] <= data_in;
        if(read) data_out <= mem[address];
    end

endmodule