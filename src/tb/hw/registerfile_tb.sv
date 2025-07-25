module registerfile_tb #(

    parameter int DATA_WIDTH = 32,
    parameter int NUM_REGISTERS = 32
);

    logic clk;
    logic rst;
    logic write;

  	logic [$clog2(NUM_REGISTERS)-1:0] reg_rd0;
  	logic [$clog2(NUM_REGISTERS)-1:0] reg_rd1;
  	logic [$clog2(NUM_REGISTERS)-1:0] reg_wr;

  	logic [DATA_WIDTH-1:0] data_in;

  	logic [DATA_WIDTH-1:0] data_out0;
  	logic [DATA_WIDTH-1:0] data_out1;

    registerfile #(
        .DATA_WIDTH(DATA_WIDTH),
        .NUM_REGISTERS(NUM_REGISTERS)
    ) DUT (
        .clk(clk),
      	.rst(rst),
        .write(write),
        .reg_rd0(reg_rd0),
      	.reg_rd1(reg_rd1),
      	.reg_wr(reg_wr),
        .data_in(data_in),
      	.data_out0(data_out0),
      	.data_out1(data_out1)
    );

    //Clock generation block
    initial begin: generate_clk
        clk <= 1'b0;
        forever #5 clk <= ~clk;
    end

    initial begin
      	logic [$clog2(NUM_REGISTERS)-1:0] addr;
      	logic [DATA_WIDTH-1:0] test_data0;
     	logic [DATA_WIDTH-1:0] test_data1;
      
       	// Initialize all control signals
      	rst <= 1'b1;
        write <= 1'b0;
      	reg_rd0 <= '0;
        reg_rd1 <= '0;
        reg_wr <= '0;
        data_in <= '0;
        
        repeat(2) @(posedge clk);
      
      	rst <= 1'b0;
      
     	@(posedge clk);
      	
      	//Write some data to the 0th register
        addr = 5'b00000;
      	test_data0 = $urandom;
        write   <= 1'b1;
      
      	data_in <= test_data0;
        reg_wr <= addr;
        @(posedge clk);
      
      	//Write some data to the 1st register
        addr = 5'b00001;
      	test_data1 = $urandom;
        write   <= 1'b1;
      
      	data_in <= test_data1;
        reg_wr <= addr;
        @(posedge clk);
      	
      
      	//Read from the 0th and 1st registers
      	write <= 1'b0;
      	reg_rd0 <= 5'b00000;
      	reg_rd1 <= 5'b00001;
        @(posedge clk);
		
      $display("Test_data0: 0x%h", test_data0);	
      $display("Test_data1: 0x%h", test_data1);
      $display("Data_Out0: 0x%h", data_out0);
      $display("Data_Out1: 0x%h", data_out1);

        //Test Write-First-Then-Read Functionality
        write <= 1'b1;
        addr = 5'b00010;
        test_data1 = $urandom;
        test_data0 = test_data1;
        data_in <= test_data1;
        reg_wr <= addr;

        reg_rd0 <= 5'b00010;
        reg_rd1 <= 5'b00010;

        @(posedge clk);
        $display("WFTR Test_data0: 0x%h", test_data0);	
        $display("WFTR Test_data1: 0x%h", test_data1);
        $display("WFTR Data_Out0: 0x%h", data_out0);
        $display("WFTR Data_Out1: 0x%h", data_out1);
        disable generate_clk;

    end
  
endmodule