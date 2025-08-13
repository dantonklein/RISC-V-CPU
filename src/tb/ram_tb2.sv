//This testbench was written while the data_ram didnt have the access fault check.

module ram_tb;

    logic clk = 1'b0;

    logic[15:0] address;
    logic[31:0] data_in;
    logic write;
    logic read;
    logic[2:0] funct3;
    
    logic[31:0] data_out;

    data_ram #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(16)
    ) DUT (
        .clk(clk),
        .address(address),
        .data_in(data_in),
        .write(write),
        .read(read),
        .funct3(funct3),
        .data_out(data_out)
    );

    //Clock generation block
    initial begin: generate_clk
        clk <= 1'b0;
        forever #5 clk <= ~clk;
    end

    initial begin
        logic [15:0] addr;
      	logic [31:0] test_data;
      
       	// Initialize all control signals
        write <= 1'b0;
        read <= 1'b0;
        address <= '0;
        data_in <= '0;
        funct3 <= 3'b000;
        // Wait for a few clock cycles
        repeat(2) @(posedge clk);
      	
      	//SB 
        addr = 16'hAAAA;
      	test_data = 32'h000000FF & $urandom;
        funct3 <= 3'b000;
        write   <= 1'b1;
      
      	data_in <= test_data;
        address <= addr;
        @(posedge clk);
        write <= 1'b0;
        @(posedge clk);
      	//LB from the same address
      	write <= 1'b0;
        read <= 1'b1;
        address <= addr;
        @(posedge clk);
        $display("SB and LB test address:%x input:%x, output:%x", address, data_in, data_out);


        //SH 
        addr = 16'hBBBB;
      	test_data = 32'h0000FFFF & $urandom;
        funct3 <= 3'b001;
        write   <= 1'b1;
      
      	data_in <= test_data;
        address <= addr;
      	@(posedge clk);	
		write <= 1'b0;
        @(posedge clk);
        //LH from the same address
      	write <= 1'b0;
        read <= 1'b1;
        address <= addr;
        @(posedge clk);
        $display("SH and LH test address:%x input:%x, output:%x", address, data_in, data_out);

        // //SH testing boundary condition
        // addr = 16'hFFFF;
        // test_data = 32'h0000FFFF & $urandom;
        // funct3 <= 3'b001;
        // write   <= 1'b1;
      
      	// data_in <= test_data;
        // address <= addr;
      	// @(posedge clk);	
		// write <= 1'b0;
        // @(posedge clk);

        // //LH from the same address
        // write <= 1'b0;
        // read <= 1'b1;
        // address <= addr;
        // @(posedge clk);
        // $display("SH and LH test with max address address:%x input:%x, output:%x", address, data_in, data_out);

        //SW 
        addr = 16'h2222;
      	test_data = $urandom;
        funct3 <= 3'b010;
        write   <= 1'b1;
      
      	data_in <= test_data;
        address <= addr;
      	@(posedge clk);	
		write <= 1'b0;
        @(posedge clk);
        //LW from the same address
      	write <= 1'b0;
        read <= 1'b1;
        address <= addr;
        @(posedge clk);
        $display("SW and LW test address:%x input:%x, output:%x", address, data_in, data_out);


        // //SW testing max addy
        // addr = 16'hFFFF;
      	// test_data = $urandom;
        // funct3 <= 3'b010;
        // write   <= 1'b1;
      
      	// data_in <= test_data;
        // address <= addr;
      	// @(posedge clk);	
		// write <= 1'b0;
        // @(posedge clk);
        // //LW from the same address
      	// write <= 1'b0;
        // read <= 1'b1;
        // address <= addr;
        // @(posedge clk);
        // $display("SW and LW test with max address address:%x input:%x, output:%x", address, data_in, data_out);

        // //SW testing max addy - 1
        // addr = 16'hFFFE;
      	// test_data = $urandom;
        // funct3 <= 3'b010;
        // write   <= 1'b1;
      
      	// data_in <= test_data;
        // address <= addr;
      	// @(posedge clk);	
		// write <= 1'b0;
        // @(posedge clk);
        // //LW from the same address
      	// write <= 1'b0;
        // read <= 1'b1;
        // address <= addr;
        // @(posedge clk);
        // $display("SW and LW test with max address - 1 address:%x input:%x, output:%x", address, data_in, data_out);

        // //SW testing max addy - 2
        // addr = 16'hFFFD;
      	// test_data = $urandom;
        // funct3 <= 3'b010;
        // write   <= 1'b1;
      
      	// data_in <= test_data;
        // address <= addr;
      	// @(posedge clk);	
		// write <= 1'b0;
        // @(posedge clk);
        // //LW from the same address
      	// write <= 1'b0;
        // read <= 1'b1;
        // address <= addr;
        // @(posedge clk);
        // $display("SW and LW test with max address - 2 address:%x input:%x, output:%x", address, data_in, data_out);


        disable generate_clk;

    end
  
endmodule