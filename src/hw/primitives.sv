//Danton Klein
//This file contains multiple simple entities that get utilized a lot in larger designs. Most of these are based on Dr. Gregory Stitt's SystemVerilog tutorial.

module mux2x1
#(
    parameter int WIDTH = 32
)
(
    input logic[WIDTH-1:0] in0,
    input logic[WIDTH-1:0] in1,
    input logic select,
    output logic[WIDTH-1:0] data_out
);

    assign data_out = select == 1'b1 ? in1 : in0;

endmodule

module mux3x1
#(
    parameter int WIDTH = 32
)
(
    input logic[WIDTH-1:0] in0,
    input logic[WIDTH-1:0] in1,
    input logic[WIDTH-1:0] in2,
    input logic[1:0] select,
    output logic[WIDTH-1:0] data_out
);

    always_comb begin
        case(select)
            2'd0: data_out = in0;
            2'd1: data_out = in1;
            2'd2: data_out = in2;
            2'd3: data_out = '0;
        endcase
    end

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

//this is not being used
module n_bit_saturation_counter #(
    parameter int width = 2
)(
    input logic clk,
    input logic rst,
    input logic count_up, count_down,
    output logic[width-1:0] count
);
    always_ff @(posedge clk or posedge rst) begin
        if(rst) count <= 1'b1;
        else begin
            case ({count_up,count_down})
                2'b01: if(count != 0) count <= count - 1'b1;
                2'b10: if(count != (2 ** width - 1)) count <= count + 1'b1;
                default: count <= count;
            endcase
        end
    end
endmodule