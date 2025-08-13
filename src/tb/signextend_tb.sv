module signextend_tb #(

    parameter int DATA_WIDTH = 32
);

    logic clk;

  	logic [31:0] data_in;
    logic [2:0] funct3;

  	logic [DATA_WIDTH-1:0] data_out;

    loads_sign_extend #(
        .DATA_WIDTH(DATA_WIDTH)
    ) DUT (
        .in(data_in),
        .funct3(funct3),
      	.out(data_out)
    );

    //Clock generation block
    initial begin: generate_clk
        clk <= 1'b0;
        forever #5 clk <= ~clk;
    end

    initial begin
        //LBU
      	data_in <= 32'h00000098;
        funct3 <= 3'b100;
        @(posedge clk);
        $display("LBU input:%0d, output:%0d", data_in, data_out);

        //LHU
      	data_in <= 32'h0000BA98;
        funct3 <= 3'b101;
        @(posedge clk);
        $display("LHU input:%0d, output:%0d", data_in, data_out);

        //LW
      	data_in <= 32'hFEDCBA98;
        funct3 <= 3'b010;
        @(posedge clk);
        $display("LW input:%0d, output:%0d", data_in, data_out);

        //LB with negative number
      	data_in <= 32'h000000FF;
        funct3 <= 3'b000;
        @(posedge clk);
        $display("Negative LB input:%0d, output:%0d", $signed(data_in[7:0]), $signed(data_out));

        //LB with positive number
      	data_in <= 32'h0000007F;
        funct3 <= 3'b000;
        @(posedge clk);
        $display("Positive LB input:%0d, output:%0d", data_in, data_out);
        
        //LH with negative number
      	data_in <= 32'h0000FFFF;
        funct3 <= 3'b001;
        @(posedge clk);
        $display("Negative LH input:%0d, output:%0d", $signed(data_in[15:0]), $signed(data_out));

        //LH with positive number
      	data_in <= 32'h00007FFF;
        funct3 <= 3'b001;
        @(posedge clk);
        $display("Positive LH input:%0d, output:%0d", data_in, data_out);
        
        disable generate_clk;

    end
  
endmodule