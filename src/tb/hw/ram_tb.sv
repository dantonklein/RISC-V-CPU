`timescale 1 ns / 100 ps

module ram_tb #(
    parameter int NUM_TESTS = 1000,

    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 32
);
    logic clk = 1'b0;
    logic rst;

    logic[ADDR_WIDTH-1:0] address;
    logic[DATA_WIDTH-1:0] data_in;
    logic write;
    logic read;
    
    logic[DATA_WIDTH-1:0] data_out;

    ram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
    ) DUT (

    );
endmodule