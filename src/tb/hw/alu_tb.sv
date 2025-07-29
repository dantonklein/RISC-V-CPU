`timescale 1 ns / 100 ps

module alu_tb #(

    parameter int DATA_WIDTH = 32,
    parameter int NUM_TESTS = 10000
);
    logic clk;
    logic [DATA_WIDTH-1:0] input0;
    logic [DATA_WIDTH-1:0] input1;
    logic [3:0] aluselect;

    logic [DATA_WIDTH-1:0] correct_out;
    logic [DATA_WIDTH-1:0] out;
    logic correct_is_zero;
    logic is_zero;

    alu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) DUT (
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

        logic [3:0] aluselect_temp;
        for (int i = 0; i < NUM_TESTS; i++) begin
            aluselect_temp = $urandom_range(0,13);
            aluselect <= aluselect_temp;
            input0 <= $urandom;
            if(aluselect_temp > 1 && aluselect_temp < 5) begin
                input1 <= $urandom_range(0,31);
            end
            else begin
                input1 <= $urandom;
            end
            @(posedge clk);

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

        end
        $display("Tests Finished.");
        disable generate_clk;
    end
    
endmodule