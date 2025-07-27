module alu
#(
    parameter int DATA_WIDTH = 32
)
(
    input logic [DATA_WIDTH-1:0] input0,
    input logic [DATA_WIDTH-1:0] input1,

    input logic [3:0] aluop,

    output logic [DATA_WIDTH-1:0] out,
    output logic is_zero
);
always_comb begin
    is_zero = 1'b0;

    case(aluop)
        //Addition
        4'd0: out = input0 + input1;
        //Subtraction
        4'd1: out = input0 - input1;
        //Shift left
        4'd2: out = input0 << input1;
        //Shift right logical
        4'd3: out = input0 >> input1;
        //Shift right arithmetic
        4'd4: out = input0 >>> input1;
        //Bitwise And
        4'd5: out = input0 & input1;
        //Bitwise Or
        4'd6: out = input0 | input1;
        //Bitwise Xor
        4'd7: out = input0 ^ input1;
        //Set if less than, 2's complement
        4'd8: out = signed'(input0) < signed'(input1);
        //Set if less than, unsigned
        4'd9: out = input0 < input1;

        default: out = 0;
    endcase

    if (out == 0) is_zero = 1'b1;
end

endmodule