module alu
#(
    parameter int DATA_WIDTH = 32
)
(
    input logic [DATA_WIDTH-1:0] input0,
    input logic [DATA_WIDTH-1:0] input1,

    input logic [3:0] aluselect,

    //output logic is_zero,
    output logic [DATA_WIDTH-1:0] out
);
always_comb begin
    is_zero = 1'b0;

    case(aluselect)
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
        // //For BNE
        // 4'd10: out = input0 == input1;
        // //For BLT
        // 4'd11: out = signed'(input0) >= signed'(input1);
        // //For BLTU
        // 4'd12: out = input0 >= input1;
         //For LUI
         4'd10: out = input1 + 4;
         default: out = 0;
    endcase

    //if (out == 0) is_zero = 1'b1;
end

endmodule

module branch_alu
#(
    parameter int DATA_WIDTH = 32
)
(
    input logic [DATA_WIDTH-1:0] input0,
    input logic [DATA_WIDTH-1:0] input1,

    input logic [2:0] funct3,

    output logic out;
    //output logic is_zero
);
always_comb begin
    out = 1'b0;
    case(funct3)
        //BEQ
        3'b000: out = input0 == input1;
        //BNE
        3'b001: out = input0 != input1;
        //BLT
        3'b100: out = signed'(input0) < signed'(input1);
        //BGE
        3'b101: out = signed'(input0) >= signed'(input1);
        //BLTU
        3'b110: out = input0 < input1;
        //BGEU
        3'b111: out = input0 >= input1;
        
    endcase
end
endmodule