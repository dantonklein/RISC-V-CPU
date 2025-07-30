//I need to remake this shit
module ram_tb #(

    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 16
);

    logic clk = 1'b0;

    logic[ADDR_WIDTH-1:0] address;
    logic[DATA_WIDTH-1:0] data_in;
    logic write;
    logic read;
    
  logic[DATA_WIDTH-1:0] data_out;

    ram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) DUT (
        .clk(clk),
        .address(address),
        .data_in(data_in),
        .write(write),
        .read(read),
      .data_out(data_out)
    );

    //Clock generation block
    initial begin: generate_clk
        clk <= 1'b0;
        forever #5 clk <= ~clk;
    end

    initial begin
        logic [ADDR_WIDTH-1:0] addr;
      	logic [DATA_WIDTH-1:0] test_data;
      
       	// Initialize all control signals
        write <= 1'b0;
        read <= 1'b0;
        address <= '0;
        data_in <= '0;
        
        // Wait for a few clock cycles
        repeat(2) @(posedge clk);
      	
      	//Write some data to the ram
        addr = $urandom;
      	test_data = $urandom;
        write   <= 1'b1;
      
      	data_in <= test_data;
        address <= addr;
        @(posedge clk);
      
      
      	//Read from the same address
      	write <= 1'b0;
        read <= 1'b1;
        address <= addr;
        @(posedge clk);
      
      	@(posedge clk);	
		
      $display("Test_data: 0x%h", test_data);	
      $display("Data_Out: 0x%h", data_out);
      $display("Address: 0x%h", address);
        disable generate_clk;

    end
  
endmodule