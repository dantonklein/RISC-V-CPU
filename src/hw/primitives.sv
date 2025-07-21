//Danton Klein
//This file contains multiple simple entities that get utilized a lot in larger designs. Most of these are based on Dr. Gregory Stitt's SystemVerilog tutorial.

module mux2x1
#(
    parameter int WIDTH = 1
)
(
    input logic[WIDTH-1:0] in0,
    input logic[WIDTH-1:0] in1,
    input logic select,
    output logic[WIDTH-1:0] data_out
);

    assign data_out = select == 1'b1 ? in1 : in0;

endmodule

module register
#(
    parameter int WIDTH = 32
)
(
    input logic[WIDTH-1:0] in,
    input logic clk,
    input logic reset,
    input logic enable,
    output logic[WIDTH-1:0] data_out
);

    always_ff @(posedge clk or posedge reset) begin
        if(reset)
            data_out <= '0;

        else if (enable)
            data_out <= in;
    end

endmodule

module delay
#(
    parameter int WIDTH = 32,
    parameter int CYCLES = 2
)
(
    input logic[WIDTH-1:0] in,
    output logic[WIDTH-1:0] data_out,
    input logic clk,
    input logic reset,
    input logic enable
);
    logic [WIDTH-1:0] regs[CYCLES+1];

    assign regs[0] = in;
    assign out = regs[CYCLES];

    for (genvar i = 0; i < CYCLES; i++) begin :register_array
        register #(.WIDTH(WIDTH)) register_array (
            .clk(clk),
            .reset(reset),
            .enable(enable),
            .in(regs[i]),
            .data_out(regs[i+1])
        );
    end

endmodule