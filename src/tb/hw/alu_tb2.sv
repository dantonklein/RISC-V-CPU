`timescale 1 ns / 100 ps

module alu_tb2 #(

    parameter int DATA_WIDTH = 32,
    parameter int NUM_TESTS = 10000
);
    logic clk;
    logic [DATA_WIDTH-1:0] input0;
    logic [DATA_WIDTH-1:0] input1;
    logic [3:0] aluselect;

    logic [2:0] ALUOp;
    logic [6:0] Funct7;
    logic [2:0] Funct3;

    logic [DATA_WIDTH-1:0] correct_out;
    logic [DATA_WIDTH-1:0] out;
    logic correct_is_zero;
    logic is_zero;

    alucontroller DUT1 (
        .ALUOp(ALUOp),
        .Funct7(Funct7),
        .Funct3(Funct3),
        .aluselect(aluselect)
    );

    alu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) DUT2 (
        .input0(input0),
        .input1(input1),
        .aluselect(aluselect),
        .out(out),
        .is_zero(is_zero)
    );

    //Clock generation block
    initial begin: generate_clk
        clk <= 1'b0;
        forever #5 clk <= ~clk;
    end

    initial begin
        logic [31:0] instruction;
        //Test ADD

        //Test SUB

        //Test SLL

        //Test SLT

        //Test SLTU

        //Test XOR

        //Test SRL

        //Test SRA

        //Test OR

        //Test AND

        //Test 

        if(aluselect == 0) correct_out = input0 + input1;
        else if(aluselect == 1) correct_out = input0 - input1;
        else if(aluselect == 2) correct_out = input0 << input1;
        else if(aluselect == 3) correct_out = input0 >> input1;
        else if(aluselect == 4) correct_out = input0 >>> input1;
        else if(aluselect == 5) correct_out = input0 & input1;
        else if(aluselect == 6) correct_out = input0 | input1;
        else if(aluselect == 7) correct_out = input0 ^ input1;
        else if(aluselect == 8) correct_out = signed'(input0) < signed'(input1);
        else if(aluselect == 9) correct_out = input0 < input1;
        else if(aluselect == 10) correct_out = input0 == input1;
        else if(aluselect == 11) correct_out = signed'(input0) >= signed'(input1);
        else if(aluselect == 12) correct_out = input0 >= input1;
        else if(aluselect == 13) correct_out = input1;
        else correct_out = 0;
        correct_is_zero = correct_out == 0;

        if(out != correct_out) begin
            $display("ERROR (time %0t): out = %h instead of %h for aluselect %h.", $realtime, out, correct_out, aluselect);
        end
        if(is_zero != correct_is_zero) begin
            $display("ERROR (time %0t): is_zero = %h instead of %h for aluselect %h.", $realtime, is_zero, correct_is_zero, aluselect);
        end
        $display("Tests Finished.");
        disable generate_clk;
    end
    
endmodule