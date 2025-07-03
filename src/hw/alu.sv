module alu
#(
    parameter int DATA_WIDTH = 32,
    parameter int CONTROL_WIDTH = 4
)
(
    input logic [DATA_WIDTH-1:0] input0,
    input logic [DATA_WIDTH-1:0] input1,

    input logic [CONTROL_WIDTH-1:0] op,

    output logic [DATA_WIDTH-1:0] out,
    output logic is_zero
);


endmodule