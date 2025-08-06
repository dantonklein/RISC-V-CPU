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

    task update_is_zero;
        input logic[31:0] c_out;
        output logic c_is_zero;
        begin
            c_is_zero = c_out == 0;
        end
    endtask

    task automatic update_inputs;
        input logic[2:0] in_ALUOp;
        input logic[6:0] in_Funct7;
        input logic[2:0] in_Funct3;
        input logic[31:0] in_input0;
        input logic[31:0] in_input1;
        ref logic[2:0] out_ALUOp;
        ref logic[6:0] out_Funct7;
        ref logic[2:0] out_Funct3;
        ref logic[31:0] out_input0;
        ref logic[31:0] out_input1;
        begin
            out_ALUOp = in_ALUOp;
            out_Funct7 = in_Funct7;
            out_Funct3 = in_Funct3;
            out_input0 = in_input0;
            out_input1 = in_input1;
        end
    endtask
    task check_output;
        input logic[31:0] in_out;
        input logic[31:0] in_correct_out;
        input logic in_is_zero;
        input logic in_correct_is_zero;
        begin
            $display("\ninput0: %h, input1: %h", input0, input1);
            $display("out: %h, correct_out: %h, is_zero: %h, correct_is_zero: %h",in_out, in_correct_out, in_is_zero, in_correct_is_zero);

            if(in_out != in_correct_out) begin
                $display("ERROR (time %0t): out = %h instead of %h.", $realtime, out, correct_out);
            end
            if(in_is_zero != in_correct_is_zero) begin
                $display("ERROR (time %0t): is_zero = %h instead of %h.", $realtime, is_zero, correct_is_zero);
            end
            $display("\n");
        end
    endtask
    //Clock generation block
    initial begin: generate_clk
        clk <= 1'b0;
        forever #5 clk <= ~clk;
    end

    initial begin

        $display("Test ADD");
        update_inputs(3'd0,7'b0000000,3'b000,$urandom,$urandom,ALUOp,Funct7,Funct3,input0,input1);

        @(posedge clk);
        correct_out = input0 + input1;
        update_is_zero(correct_out, correct_is_zero);
        check_output(out, correct_out, is_zero, correct_is_zero);

        $display("Test SUB");
        update_inputs(3'd0,7'b0100000,3'b000,$urandom,$urandom,ALUOp,Funct7,Funct3,input0,input1);
        
        @(posedge clk);
        correct_out = input0 - input1;
        correct_is_zero = correct_out == 0;
        check_output(out, correct_out, is_zero, correct_is_zero);

        $display("Test SLL");
        update_inputs(3'd0,7'b0000000,3'b001,$urandom,$urandom_range(0,31),ALUOp,Funct7,Funct3,input0,input1);
        
        @(posedge clk);
        correct_out = input0 << input1;
        update_is_zero(correct_out, correct_is_zero);
        check_output(out, correct_out, is_zero, correct_is_zero);

        $display("Test SLT with less than");
        update_inputs(3'd0,7'b0000000,3'b010,32'd10,-32'd10,ALUOp,Funct7,Funct3,input0,input1);
        
        @(posedge clk);
        correct_out = signed'(input0) < signed'(input1);
        update_is_zero(correct_out, correct_is_zero);
        check_output(out, correct_out, is_zero, correct_is_zero);
        
        $display("Test SLT with greater than");
        update_inputs(3'd0,7'b0000000,3'b010,-32'd10,32'd10,ALUOp,Funct7,Funct3,input0,input1);
        
        @(posedge clk);
        correct_out = signed'(input0) < signed'(input1);
        update_is_zero(correct_out, correct_is_zero);
        check_output(out, correct_out, is_zero, correct_is_zero);
        
        $display("Test SLTU with less than");
        update_inputs(3'd0,7'b0000000,3'b011,32'd20,32'd10,ALUOp,Funct7,Funct3,input0,input1);
        
        @(posedge clk);
        correct_out = input0 < input1;
        update_is_zero(correct_out, correct_is_zero);
        check_output(out, correct_out, is_zero, correct_is_zero);
        
        $display("Test SLTU with greater than");
        update_inputs(3'd0,7'b0000000,3'b011,32'd10,32'd20,ALUOp,Funct7,Funct3,input0,input1);
        
        @(posedge clk);
        correct_out = input0 < input1;
        update_is_zero(correct_out, correct_is_zero);
        check_output(out, correct_out, is_zero, correct_is_zero);

        $display("Test XOR");
        update_inputs(3'd0,7'b0000000,3'b100,$urandom,$urandom,ALUOp,Funct7,Funct3,input0,input1);
        
        @(posedge clk);
        correct_out = input0 ^ input1;
        update_is_zero(correct_out, correct_is_zero);
        check_output(out, correct_out, is_zero, correct_is_zero);
        
        $display("Test SRL");
        update_inputs(3'd0,7'b0000000,3'b101,$urandom,$urandom_range(0,31),ALUOp,Funct7,Funct3,input0,input1);
        
        @(posedge clk);
        correct_out = input0 >> input1;
        update_is_zero(correct_out, correct_is_zero);
        check_output(out, correct_out, is_zero, correct_is_zero);
        
        $display("Test SRA");
        update_inputs(3'd0,7'b0100000,3'b101,$urandom,$urandom_range(0,31),ALUOp,Funct7,Funct3,input0,input1);
        
        @(posedge clk);
        correct_out = input0 >>> input1;
        update_is_zero(correct_out, correct_is_zero);
        check_output(out, correct_out, is_zero, correct_is_zero);
        
        $display("Test OR");
        update_inputs(3'd0,7'b0000000,3'b110,$urandom,$urandom,ALUOp,Funct7,Funct3,input0,input1);
        
        @(posedge clk);
        correct_out = input0 | input1;
        update_is_zero(correct_out, correct_is_zero);
        check_output(out, correct_out, is_zero, correct_is_zero);
        
        $display("Test AND");
        update_inputs(3'd0,7'b0000000,3'b111,$urandom,$urandom,ALUOp,Funct7,Funct3,input0,input1);
        
        @(posedge clk);
        correct_out = input0 & input1;
        update_is_zero(correct_out, correct_is_zero);
        check_output(out, correct_out, is_zero, correct_is_zero);
        
        $display("Test ADDI");
        update_inputs(3'd1,7'b0000000,3'b000,$urandom,$urandom,ALUOp,Funct7,Funct3,input0,input1);
        
        @(posedge clk);
        correct_out = input0 + input1;
        update_is_zero(correct_out, correct_is_zero);
        check_output(out, correct_out, is_zero, correct_is_zero);
        
        $display("Test SLTI");
        update_inputs(3'd1,7'b0000000,3'b010,$urandom,$urandom,ALUOp,Funct7,Funct3,input0,input1);
        
        @(posedge clk);
        correct_out = signed'(input0) < signed'(input1);
        update_is_zero(correct_out, correct_is_zero);
        check_output(out, correct_out, is_zero, correct_is_zero);
        
        $display("Test SLTIU");
        update_inputs(3'd1,7'b0000000,3'b011,$urandom,$urandom,ALUOp,Funct7,Funct3,input0,input1);
        
        @(posedge clk);
        correct_out = input0 < input1;
        update_is_zero(correct_out, correct_is_zero);
        check_output(out, correct_out, is_zero, correct_is_zero);
        
        $display("Test XORI");
        update_inputs(3'd1,7'b0000000,3'b100,$urandom,$urandom,ALUOp,Funct7,Funct3,input0,input1);
        
        @(posedge clk);
        correct_out = input0 ^ input1;
        update_is_zero(correct_out, correct_is_zero);
        check_output(out, correct_out, is_zero, correct_is_zero);
        
        $display("Test ORI");
        update_inputs(3'd1,7'b0000000,3'b110,$urandom,$urandom,ALUOp,Funct7,Funct3,input0,input1);
        
        @(posedge clk);
        correct_out = input0 | input1;
        update_is_zero(correct_out, correct_is_zero);
        check_output(out, correct_out, is_zero, correct_is_zero);
        
        $display("Test ANDI");
        update_inputs(3'd1,7'b0000000,3'b111,$urandom,$urandom,ALUOp,Funct7,Funct3,input0,input1);
        
        @(posedge clk);
        correct_out = input0 & input1;
        update_is_zero(correct_out, correct_is_zero);
        check_output(out, correct_out, is_zero, correct_is_zero);
        
        $display("Test SLLI");
        update_inputs(3'd1,7'b0000000,3'b001,$urandom,$urandom_range(0,31),ALUOp,Funct7,Funct3,input0,input1);
        
        @(posedge clk);
        correct_out = input0 << input1;
        update_is_zero(correct_out, correct_is_zero);
        check_output(out, correct_out, is_zero, correct_is_zero);
        
        $display("Test SRLI");
        update_inputs(3'd1,7'b0000000,3'b101,$urandom,$urandom_range(0,31),ALUOp,Funct7,Funct3,input0,input1);
        
        @(posedge clk);
        correct_out = input0 >> input1;
        update_is_zero(correct_out, correct_is_zero);
        check_output(out, correct_out, is_zero, correct_is_zero);
        
        $display("Test SRAI");
        update_inputs(3'd1,7'b0100000,3'b101,$urandom,$urandom_range(0,31),ALUOp,Funct7,Funct3,input0,input1);
        
        @(posedge clk);
        correct_out = input0 >>> input1;
        update_is_zero(correct_out, correct_is_zero);
        check_output(out, correct_out, is_zero, correct_is_zero);
        
        $display("Test LUI");
        update_inputs(3'd2,7'b0000000,3'b000,$urandom,$urandom,ALUOp,Funct7,Funct3,input0,input1);
        
        @(posedge clk);
        correct_out = input1 + 4;
        update_is_zero(correct_out, correct_is_zero);
        check_output(out, correct_out, is_zero, correct_is_zero);
        
        $display("Test Load/Store");
        update_inputs(3'd3,7'b0000000,3'b000,$urandom,$urandom,ALUOp,Funct7,Funct3,input0,input1);
        
        @(posedge clk);
        correct_out = input0 + input1;
        update_is_zero(correct_out, correct_is_zero);
        check_output(out, correct_out, is_zero, correct_is_zero);
        
        // $display("BEQ for equal inputs");
        // update_inputs(3'd4,7'b0000000,3'b000,32'h0f0f0f0f,32'h0f0f0f0f,ALUOp,Funct7,Funct3,input0,input1);
        
        // @(posedge clk);
        // correct_out = input0 - input1;
        // update_is_zero(correct_out, correct_is_zero);
        // check_output(out, correct_out, is_zero, correct_is_zero);
        
        // $display("BEQ for not equal inputs");
        // update_inputs(3'd4,7'b0000000,3'b000,32'h0f0f0f0f,32'h0f0f0f0E,ALUOp,Funct7,Funct3,input0,input1);
        
        // @(posedge clk);
        // correct_out = input0 - input1;
        // update_is_zero(correct_out, correct_is_zero);
        // check_output(out, correct_out, is_zero, correct_is_zero);
        
        // $display("BNE for not equal inputs");
        // update_inputs(3'd4,7'b0000000,3'b001,32'h0f0f0f0f,32'h0f0f0f0E,ALUOp,Funct7,Funct3,input0,input1);
        
        // @(posedge clk);
        // correct_out = input0 == input1;
        // update_is_zero(correct_out, correct_is_zero);
        // check_output(out, correct_out, is_zero, correct_is_zero);
        
        // $display("BNE for equal inputs");
        // update_inputs(3'd4,7'b0000000,3'b001,32'h0f0f0f0f,32'h0f0f0f0f,ALUOp,Funct7,Funct3,input0,input1);
        
        // @(posedge clk);
        // correct_out = input0 == input1;
        // update_is_zero(correct_out, correct_is_zero);
        // check_output(out, correct_out, is_zero, correct_is_zero);
        
        // $display("BLT for less than");
        // update_inputs(3'd4,7'b0000000,3'b100,-32'd10,32'd10,ALUOp,Funct7,Funct3,input0,input1);
        
        // @(posedge clk);
        // correct_out = signed'(input0) >= signed'(input1);
        // update_is_zero(correct_out, correct_is_zero);
        // check_output(out, correct_out, is_zero, correct_is_zero);
        
        // $display("BLT for greater than");
        // update_inputs(3'd4,7'b0000000,3'b100,32'd10,-32'd10,ALUOp,Funct7,Funct3,input0,input1);
        
        // @(posedge clk);
        // correct_out = signed'(input0) >= signed'(input1);
        // update_is_zero(correct_out, correct_is_zero);
        // check_output(out, correct_out, is_zero, correct_is_zero);
        
        // $display("BGE for greater than");
        // update_inputs(3'd4,7'b0000000,3'b101,32'd10,-32'd10,ALUOp,Funct7,Funct3,input0,input1);
        
        // @(posedge clk);
        // correct_out = signed'(input0) < signed'(input1);
        // update_is_zero(correct_out, correct_is_zero);
        // check_output(out, correct_out, is_zero, correct_is_zero);
        
        // $display("BGE for less than");
        // update_inputs(3'd4,7'b0000000,3'b101,-32'd10,32'd10,ALUOp,Funct7,Funct3,input0,input1);
        
        // @(posedge clk);
        // correct_out = signed'(input0) < signed'(input1);
        // update_is_zero(correct_out, correct_is_zero);
        // check_output(out, correct_out, is_zero, correct_is_zero);
        
        // $display("BGE for equal to");
        // update_inputs(3'd4,7'b0000000,3'b101,32'd10,32'd10,ALUOp,Funct7,Funct3,input0,input1);
        
        // @(posedge clk);
        // correct_out = signed'(input0) < signed'(input1);
        // update_is_zero(correct_out, correct_is_zero);
        // check_output(out, correct_out, is_zero, correct_is_zero);
        
        // $display("BLTU for less than");
        // update_inputs(3'd4,7'b0000000,3'b110,32'd10,32'd20,ALUOp,Funct7,Funct3,input0,input1);
        
        // @(posedge clk);
        // correct_out = input0 >= input1;
        // update_is_zero(correct_out, correct_is_zero);
        // check_output(out, correct_out, is_zero, correct_is_zero);
        
        // $display("BLTU for greater than");
        // update_inputs(3'd4,7'b0000000,3'b110,32'd20,32'd10,ALUOp,Funct7,Funct3,input0,input1);
        
        // @(posedge clk);
        // correct_out = input0 >= input1;
        // update_is_zero(correct_out, correct_is_zero);
        // check_output(out, correct_out, is_zero, correct_is_zero);
        
        // $display("BLTU for equal to");
        // update_inputs(3'd4,7'b0000000,3'b110,32'd20,32'd20,ALUOp,Funct7,Funct3,input0,input1);
        
        // @(posedge clk);
        // correct_out = input0 >= input1;
        // update_is_zero(correct_out, correct_is_zero);
        // check_output(out, correct_out, is_zero, correct_is_zero);
        
        // $display("BGEU for greater than");
        // update_inputs(3'd4,7'b0000000,3'b111,32'd20,32'd10,ALUOp,Funct7,Funct3,input0,input1);
        
        // @(posedge clk);
        // correct_out = input0 < input1;
        // update_is_zero(correct_out, correct_is_zero);
        // check_output(out, correct_out, is_zero, correct_is_zero);
        
        // $display("BGEU for less than");
        // update_inputs(3'd4,7'b0000000,3'b111,32'd10,32'd20,ALUOp,Funct7,Funct3,input0,input1);
        
        // @(posedge clk);
        // correct_out = input0 < input1;
        // update_is_zero(correct_out, correct_is_zero);
        // check_output(out, correct_out, is_zero, correct_is_zero);
        
        // $display("BGEU for equal to than");
        // update_inputs(3'd4,7'b0000000,3'b111,32'd20,32'd20,ALUOp,Funct7,Funct3,input0,input1);
        
        // @(posedge clk);
        // correct_out = input0 < input1;
        // update_is_zero(correct_out, correct_is_zero);
        // check_output(out, correct_out, is_zero, correct_is_zero);
        
        $display("Tests Finished.");
        disable generate_clk;
    end
    
endmodule