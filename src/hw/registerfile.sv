module registerfile 
#(
    parameter int DATA_WIDTH = 32,
    parameter int NUM_REGISTERS = 32
)
(
    input logic clk,
    //input logic rst,
    input logic write,

    input logic [$clog2(NUM_REGISTERS)-1:0] reg_rd0,
    input logic [$clog2(NUM_REGISTERS)-1:0] reg_rd1,
    input logic [$clog2(NUM_REGISTERS)-1:0] reg_wr,

    input logic [DATA_WIDTH-1:0] data_in,

    output logic [DATA_WIDTH-1:0] data_out0,
    output logic [DATA_WIDTH-1:0] data_out1
);
    logic [DATA_WIDTH-1:0] registers[NUM_REGISTERS];

    //always_ff @(posedge clk or posedge rst) begin
    always_ff @(posedge clk) begin
        // if(rst) begin
        //     for(int i = 0; i < NUM_REGISTERS; i = i + 1) begin
        //         registers[i] <= '0;
        //     end
        // end

        //else begin
            if(write) begin
                registers[reg_wr] <= data_in;
            end
        //end

    end

    always_comb begin
        if(write == 1'b1 && reg_rd0 == reg_wr) data_out0 = data_in;
        else if(reg_rd0 == 5'd0) data_out0 = '0;
        else data_out0 = registers[reg_rd0];

        if(write == 1'b1 && reg_rd1 == reg_wr) data_out1 = data_in;
        else if(reg_rd1 == 5'd0) data_out1 = '0;
        else data_out1 = registers[reg_rd1];
    end

endmodule