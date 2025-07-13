module immgen_tb #(

    parameter int DATA_WIDTH = 32
);

    logic clk;

  	logic [31:0] data_in;

  	logic [DATA_WIDTH-1:0] data_out;

    immgen #(
        .DATA_WIDTH(DATA_WIDTH)
    ) DUT (
        .inst(data_in),
      	.extended_immediate(data_out)
    );

    //Clock generation block
    initial begin: generate_clk
        clk <= 1'b0;
        forever #5 clk <= ~clk;
    end

    initial begin
        //I-type format with positive number
      	data_in <= 32'b01010101010111111111111110011111;
        @(posedge clk);
        $display("I type format with positive number input:%0d, output:%0d", $signed(data_in[31:20]), $signed(data_out));

        //I-type format with negative number
      	data_in <= 32'b11010101010111111111111110011111;
        @(posedge clk);
        $display("I type format with negative number input:%0d, output:%0d", $signed(data_in[31:20]), $signed(data_out));

        //S-type format with positive number
        data_in <= 32'b01010101111111111111101010111111;
        @(posedge clk);
        $display("S type format with positive number input:%0d, output:%0d", $signed({data_in[31:25],data_in[11:7]}), $signed(data_out));
        
        //S-type format with negative number
        data_in <= 32'b11010101111111111111101010111111;
        @(posedge clk);
        $display("S type format with negative number input:%0d, output:%0d", $signed({data_in[31:25],data_in[11:7]}), $signed(data_out));

        //SB-type with positive number
        data_in <= 32'b00101011111111111111010111111111;
        @(posedge clk);
        $display("SB type format with positive number input:%0d, output:%0d", $signed({data_in[31],data_in[7],data_in[30:25], data_in[11:8], 1'b0}), $signed(data_out));

        //SB-type with negative number
        data_in <= 32'b10101011111111111111010111111111;
        @(posedge clk);
        $display("SB type format with negative number input:%0d, output:%0d", $signed({data_in[31],data_in[7],data_in[30:25], data_in[11:8], 1'b0}), $signed(data_out));
        
        disable generate_clk;

    end
  
endmodule